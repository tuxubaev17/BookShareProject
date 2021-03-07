//
//  SignUpViewController.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 07.09.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

public enum LoginType: String {
    case phone_number
    case email
    case wrongFormat
    case empty
}

protocol SignUpViewControllerDelegate: class {
    func signUpViewControllerSuccess(_ ctrl: SignUpViewController)
    func signUpViewControllerShouldGoBack(_ ctrl: SignUpViewController)
}

class SignUpViewController: KeyboardViewController, KeyboardManagerDelegateViewController {

    private lazy var contentView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var brandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var signUpLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Sign up", comment: "")
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    private lazy var signUpTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Use your Email or Phone number to create new account", comment: "")
        label.numberOfLines = 0
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var loginTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Login", comment: "")
        return textField
    }()
    
    private lazy var agreementImageView: UIImageView = {
        let image = UIImage(named: "refusing")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var agreementTextView: UITextView = {
        let textView = UITextView()
        let string = NSLocalizedString("I agree with terms and conditions", comment: "")
        textView.text = string
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        return textView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Sign in", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(transitionToSignInVC), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        return button
    }()
    
    @objc func nextButtonPressed() {
         self.signUp()
    }
    
    private func signUp() {
        if !isAgreementChecked {
            self.showAlert(title: nil,
                           description: NSLocalizedString("To register, accept the user agreement",
                                                          comment: ""))
            return
        }
        let type = checkLoginType()
        
        switch type {
        case .email:
            self.signUpByMail()
        case .phone_number:
            self.signUpByPhone()
        case .empty:
            self.emptyLoginField()
        case .wrongFormat:
            self.wrongLoginFormat()
        }
    }
    
    private func signUpByMail() {
        guard let mail = loginTextField.text else { return }
        let signUpData = SignUpDataForConfirmPassword(login: mail,
                                                      loginType: .email)
        let vc = ConfirmPasswordController(signUpData: signUpData)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    private func signUpByPhone() {
        let vc = PinCodeViewController(title: NSLocalizedString("Sign up", comment: ""),
                                       description: NSLocalizedString("Enter SMS code", comment: ""))
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    private func emptyLoginField() {
        self.showAlert(title: NSLocalizedString("Error", comment: ""),
                       description: NSLocalizedString("Fill in the login fields!", comment: ""))
    }
    
    private func wrongLoginFormat() {
        self.showAlert(title: NSLocalizedString("Invalid data format", comment: ""),
                       description: NSLocalizedString("Enter the correct phone number or mail", comment: ""))
    }
    
    @objc func transitionToSignInVC() {
        self.delegate?.signUpViewControllerShouldGoBack(self)
    }
    
    private var pinCodeSid: String?
    
    weak var delegate: SignUpViewControllerDelegate?
    weak var keyboardDelegate: KeyboardManagerDelegate?
    let griffon = Griffon.shared
    var isAgreementChecked: Bool = false {
        didSet {
            var imageName = ""
            (isAgreementChecked) ? (imageName = "accept") : (imageName = "refusing")
            self.agreementImageView.image = UIImage(named: imageName)
        }
    }
    
    override func keyboardWasShown(notification: Notification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        
        if keyboardDelegate != nil {
            keyboardDelegate!.keyboardVisibilityChanged(with: keyboardSize!.height)
        } else {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize!.height, right: 0)
        }
    }
    
    override func keyboardWillBeHidden(notification: Notification) {
        if keyboardDelegate != nil {
            keyboardDelegate!.keyboardVisibilityChanged(with: 0)
        } else {
            self.scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
    private func checkLoginType() -> LoginType {
        guard let login = loginTextField.text else { return .empty }
        guard let signUpTypes = self.griffon.config.clientInfo?.signUpType else { return .wrongFormat }
        
        if login.isPhoneNumber() && signUpTypes.contains(.phone_number) {
            return .phone_number
        } else if login.isMail() && signUpTypes.contains(.email) {
            return .email
        } else {
            return .wrongFormat
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
      
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupScrollView()
        self.setupViews()
        self.loginTextField.delegate = self
        self.setAgreement()
        self.setupControllerConfiguration()
    }
    
    private func setAgreement(){
        self.addGestureRecognizerForAgreement()
        let griffonConfig = Griffon.shared.config
        guard let clientInfo = griffonConfig.clientInfo else { return }
        let stringURL = clientInfo.getTermsConditionUrl()
        
        let linkAgreementAttribute = getLinkAttributeForAgreement(stringURL: stringURL)
        
        agreementTextView.textContainer.maximumNumberOfLines = 2
        agreementTextView.textContainer.lineBreakMode = .byClipping
        agreementTextView.delegate = self
        agreementTextView.dataDetectorTypes = .link
        agreementTextView.attributedText = linkAgreementAttribute
        agreementTextView.delaysContentTouches = false
        agreementTextView.textAlignment = .left
    }
    
    private func addGestureRecognizerForAgreement() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(agreementTapped(tapGestureRecognizer:)))
        agreementImageView.isUserInteractionEnabled = true
        agreementImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func getLinkAttributeForAgreement(stringURL: String) -> NSMutableAttributedString {
        let linkAttributes = [
            NSAttributedString.Key.link: NSURL(string: stringURL)!,
            NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xFA5654)
        ]
        let string = NSLocalizedString("I agree with terms and conditions", comment: "")
        let font = UIFont(name: "Helvetica", size: CGFloat(13.0))!
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(0, string.count))
//        We can unсomment after configure localization
//        if LocaleLanguage().current() == "en" {
//            attributedString.setAttributes(linkAttributes, range: NSMakeRange(18, 15))
//        } else {
//            attributedString.setAttributes(linkAttributes, range: NSMakeRange(12, 29))
//        }
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, string.count))
        return attributedString
    }
    
    @objc func agreementTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.isAgreementChecked = !self.isAgreementChecked
    }
    
    override func viewDidLayoutSubviews() {
        self.setupControllerConfiguration()
    }
    
    private func setupControllerConfiguration() {
        let griffon = Griffon.shared
        let brand = griffon.config.brand
        guard let clientInfo = griffon.config.clientInfo else { return }
        self.setBrandImageFromFileManager(imageView: self.brandImageView, imageName: clientInfo.secret)
        //self.agreementTextView.setBackgroundColor(color: clientInfo.backgroundColor)
        //self.view.setBackgroundColor(color: clientInfo.backgroundColor)
        self.setNextButtonColor(buttonColor: clientInfo.buttonColor)
    }
    
    private func setSignUpTypes() {
        guard let signUpTypes = Griffon.shared.config.clientInfo?.signUpType else { return }
        
        if signUpTypes.count == 2 {
            signUpTypeLabel.text = NSLocalizedString("Login with email address or phone number", comment: "")
        } else if signUpTypes.count == 1 {
            guard let signUpType = signUpTypes.first else { return }
            if signUpType == .email {
                signUpTypeLabel.text = NSLocalizedString("Use your Phone number to create new account", comment: "")
            } else if signUpType == .phone_number {
                signUpTypeLabel.text = NSLocalizedString("Use your Email to create new account", comment: "")
            }
        }
    }
    
    private func setBrandImageFromFileManager(imageView: UIImageView, imageName: String) {
        let imageService = ImageService()
        guard let uiImage = imageService.read(fileName: imageName) else { return }
        imageView.image = uiImage
    }
    
    private func setNextButtonColor(buttonColor: ButtonColor) {
        switch buttonColor.type {
        case .gradient:
            self.nextButton.applyGradient(colours: buttonColor.colors, type: .linear)
        case .static_type:
            guard
                let firstColor = buttonColor.colors.first else {
                    return
            }
            self.nextButton.setBackgroundColor(color: firstColor)
        }
    }
    
    private func setupScrollView() {
        self.view.addSubview(scrollView)
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func setupViews() {
        [brandImageView, signUpLabel, signUpTypeLabel,
         loginTextField, agreementImageView, agreementTextView,
         nextButton, signInButton].forEach { (view) in
            self.contentView.addSubview(view)
        }
        
        brandImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        brandImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        brandImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4).isActive = true
        brandImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25).isActive = true
        
        signUpLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        signUpLabel.topAnchor.constraint(equalTo: brandImageView.bottomAnchor, constant: 15).isActive = true
        signUpLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        signUpLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        signUpTypeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        signUpTypeLabel.topAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 20).isActive = true
        signUpTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        signUpTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        loginTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loginTextField.topAnchor.constraint(equalTo: signUpTypeLabel.bottomAnchor, constant: 30).isActive = true
        loginTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        loginTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        loginTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        agreementImageView.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20).isActive = true
        agreementImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        agreementImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        agreementImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        agreementTextView.leadingAnchor.constraint(equalTo: agreementImageView.trailingAnchor, constant: 5).isActive = true
        agreementTextView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        agreementTextView.centerYAnchor.constraint(equalTo: agreementImageView.centerYAnchor).isActive = true
        agreementTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        agreementTextView.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20).isActive = true

        nextButton.topAnchor.constraint(equalTo: agreementImageView.bottomAnchor, constant: 30).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        signInButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 15).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}

extension SignUpViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let griffonConfig = Griffon.shared.config
        guard let clientInfo = griffonConfig.clientInfo else { return false }
        let stringURL = clientInfo.getTermsConditionUrl()
        guard let url = Foundation.URL(string: stringURL) else { return false }
        let webVC = WebViewController(url: url)
        self.present(webVC, animated: true)
        return false
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.signUp()
        return true
    }
}


extension SignUpViewController: PinCodeViewControllerDelegate {
    func didConfirmPinCode(provider: NetworkManager, sid: String) {
        let signUpData = SignUpDataForConfirmPassword(login: "",
                                                      loginType: .phone_number,
                                                      sid: sid)
        let vc = ConfirmPasswordController(signUpData: signUpData)
        vc.delegate = self
        self.present(vc,animated: true)
    }
    
    func pinCodeViewController(_ ctrl: PinCodeViewController, didEnterCode: String, sid: String?) {
        guard let pinSid = self.pinCodeSid else { return }
        let provider = NetworkManager.instance
        provider.verifyPinCode(sid: pinSid, code: didEnterCode , success: { (result) in
            print("Success Result : \(result)")
            self.dismiss(animated: true) {
                self.didConfirmPinCode(provider: provider, sid: result.sid)
            }
        }) { (error) in
            let errorDomain = (error as NSError).domain
            ctrl.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: errorDomain)
            print("Error : \(errorDomain)")
        }
    }
    
    func pinCodeViewController(_ ctrl: PinCodeViewController, shouldResendCodeInitial: Bool) {
        guard let phone = loginTextField.text else { return }
        let provider = NetworkManager.instance
        provider.sendPinCode(phone: phone.convertPhoneType(), success: { (result) in
            self.pinCodeSid = result.sid
            if (!shouldResendCodeInitial) {
                ctrl.showAlert(title: NSLocalizedString("Successfull", comment: ""),
                               description: NSLocalizedString("Successfull resend code", comment: ""))
            }
            ctrl.cooldownSeconds = Int(result.addInfo) ?? 90
        }) { (error) in
            print("Error in send sms code. Error: \((error as NSError).domain)")
            if (shouldResendCodeInitial) {
                self.dismiss(animated: true) {
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), description: (error as NSError).domain)
                }
            } else {
                ctrl.showAlert(title: NSLocalizedString("Error", comment: ""), description: (error as NSError).domain)
            }
        }
    }
    
    func pinCodeViewControllerShouldGoBack(_ ctrl: PinCodeViewController) {
        ctrl.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension SignUpViewController: ConfirmPasswordControllerDelegate {
    func confirmPasswordControllerSuccess(_ ctrl: ConfirmPasswordController) {
        ctrl.dismiss(animated: true) {
            self.delegate?.signUpViewControllerSuccess(self)
        }
    }
    
    func confirmPasswordControllerShouldGoBack(_ ctrl: ConfirmPasswordController) {
        ctrl.dismiss(animated: true) {
            self.delegate?.signUpViewControllerShouldGoBack(self)
        }
    }
}
