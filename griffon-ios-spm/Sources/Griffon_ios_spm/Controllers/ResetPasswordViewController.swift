//
//  ResetPasswordViewController.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 25.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

protocol ResetPasswordToPinCodeDataProtocol {
    var clientId: String { get }
    var provider: Networkable { get }
    var coolDownTime: String { get }
}

struct ResetPasswordToPinCodeData: ResetPasswordToPinCodeDataProtocol {
    var clientId: String
    var provider: Networkable
    var coolDownTime: String
}

class ResetPasswordViewController: KeyboardViewController, KeyboardManagerDelegateViewController  {
    
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
    
    private lazy var resetPasswordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Reset password", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    private lazy var resetTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Enter your email address or phone number and we will send you a password reset code", comment: "")
        label.numberOfLines = 0
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var loginTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Login", comment: "")
        return textField
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitle( NSLocalizedString("Reset", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var haveAccountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.text = NSLocalizedString("Do you have an account?", comment: "")
        return label
    }()
    
    private lazy var transitionToSignInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.underlineButton(text: NSLocalizedString("Sign in", comment: ""))
        button.titleLabel?.font =  .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(transitionToSignIn), for: .touchUpInside)
        return button
    }()
    
    @objc func resetButtonPressed(sender: UIButton) {
        self.prepareDataForCodeSend()
    }
    
    private func prepareDataForCodeSend() {
        guard
            let login = loginTextField.text,
            login.count > 0 else {
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: NSLocalizedString("Fill in the login fields!", comment: ""))
            return
        }
        
        let loginType = login.checkLoginType()
        if loginType == .wrongFormat {
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: NSLocalizedString("Enter the correct phone number or mail", comment: ""))
        } else {
            openPinCodeViewController()
        }
    }
    
    private func openPinCodeViewController() {
        let vc = PinCodeViewController(title: NSLocalizedString("Reset password", comment: ""),
                                       description: NSLocalizedString("Enter verification code", comment: ""))
        vc.delegate = self
        self.present(vc,animated: true)
    }
    
    @objc func transitionToSignIn(sender: UIButton) {
        print("Transition to sign in")
        self.dismiss(animated: true, completion: nil)
    }
    
    var keyboardDelegate: KeyboardManagerDelegate?
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let griffon = Griffon.shared
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
      
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupScrollView()
        self.setupViews()
        self.loginTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        self.setupControllerConfiguration()
    }
    
    private func setupControllerConfiguration() {
        let griffon = Griffon.shared
        guard let clientInfo = griffon.config.clientInfo else { return }
        self.setBrandImageFromFileManager(imageView: self.brandImageView, imageName: clientInfo.secret)
        self.transitionToSignInButton.setTitleColor(.blue, for: .normal)
        //self.contentView.setBackgroundColor(color: clientInfo.backgroundColor)
        self.setCheckButtonColor(buttonColor: clientInfo.buttonColor)
    }
    
    private func setBrandImageFromFileManager(imageView: UIImageView, imageName: String) {
        let imageService = ImageService()
        guard let uiImage = imageService.read(fileName: imageName) else { return }
        imageView.image = uiImage
    }
    
    private func setCheckButtonColor(buttonColor: ButtonColor) {
        self.resetButton.clipsToBounds = true
        self.resetButton.layer.cornerRadius = 5
        switch buttonColor.type {
        case .gradient:
            self.resetButton.applyGradient(colours: buttonColor.colors, type: .linear)
        case .static_type:
            guard
                let firstColor = buttonColor.colors.first else {
                    return
            }
            self.resetButton.setBackgroundColor(color: firstColor)
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
        [brandImageView, resetPasswordLabel, resetTypeLabel,
         loginTextField, resetButton, haveAccountLabel, transitionToSignInButton ].forEach { (view) in
            self.contentView.addSubview(view)
        }
        
        brandImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        brandImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        brandImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4).isActive = true
        brandImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25).isActive = true
                
        resetPasswordLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        resetPasswordLabel.topAnchor.constraint(equalTo: brandImageView.bottomAnchor, constant: 50).isActive = true
        resetPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        resetPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        resetTypeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        resetTypeLabel.topAnchor.constraint(equalTo: resetPasswordLabel.bottomAnchor, constant: 20).isActive = true
        resetTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        resetTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        loginTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loginTextField.topAnchor.constraint(equalTo: resetTypeLabel.bottomAnchor, constant: 30).isActive = true
        loginTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        loginTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        loginTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        resetButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        resetButton.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 30).isActive = true
        resetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        resetButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        haveAccountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        haveAccountLabel.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 20).isActive = true
        haveAccountLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        haveAccountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        
        if LocaleLanguage().current() == "en" {
            transitionToSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 200).isActive = true
        } else {
            transitionToSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 160).isActive = true
        }
        transitionToSignInButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 20).isActive = true
        transitionToSignInButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        transitionToSignInButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.prepareDataForCodeSend()
        return true
    }
}

extension ResetPasswordViewController: PinCodeViewControllerDelegate {
    
    func didConfirmPinCode(sid: String) {
        let resetData = ResetDataForConfirmPassword(sid: sid)
        let vc = ConfirmPasswordController(resetData: resetData)
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func pinCodeViewController(_ ctrl: PinCodeViewController, didEnterCode code: String, sid: String?) {
        guard let sid = sid else { return}
        NetworkManager.instance.verifyResetPassword(sid: sid,
                                                    code: code,
                                                    success: { (result) in
            if result.status == 200 {
                self.dismiss(animated: true) {
                    self.didConfirmPinCode(sid: sid)
                }
            } else {
                ctrl.showAlert(title: NSLocalizedString("Error", comment: ""),
                                description: result.message)
            }
        }) { (error) in
            let errorDomain = (error as NSError).domain
            ctrl.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: errorDomain)
        }
    }
    
    func pinCodeViewController(_ ctrl: PinCodeViewController, shouldResendCodeInitial: Bool) {
        guard let login = loginTextField.text else { return }
        let loginType = login.checkLoginType()
        self.sendResetCode(ctrl: ctrl,
                           username: login.convertPhoneType(),
                           resetType: loginType.rawValue,
                           shouldResendCodeInitial: shouldResendCodeInitial)
    }
    
    func sendResetCode(ctrl: PinCodeViewController, username: String, resetType: String, shouldResendCodeInitial: Bool) {
        NetworkManager.instance.sendResetCode(username: username,
                                      resetType: resetType,
                                      success: { result in
            ctrl.sid = result.sid
            if (!shouldResendCodeInitial) {
                ctrl.showAlert(title: NSLocalizedString("Successfull", comment: ""),
                               description: NSLocalizedString("Successfull resend code", comment: ""))
            }
            ctrl.cooldownSeconds = Int(result.addInfo) ?? 90
        }) { (error) in
            let errorDomain = (error as NSError).domain
            if (shouldResendCodeInitial) {
                self.dismiss(animated: true) {
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), description: errorDomain)
                }
            } else {
                ctrl.showAlert(title: NSLocalizedString("Error", comment: ""), description: errorDomain)
            }
        }
    }
    
    func pinCodeViewControllerShouldGoBack(_ ctrl: PinCodeViewController) {
        ctrl.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ResetPasswordViewController: ConfirmPasswordControllerDelegate {
    func confirmPasswordControllerSuccess(_ ctrl: ConfirmPasswordController) {
        ctrl.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func confirmPasswordControllerShouldGoBack(_ ctrl: ConfirmPasswordController) {
        ctrl.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}


