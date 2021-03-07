//
//  PinCodeViewController.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 04.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

public enum PinCodeVCInitType: String {
    case fromSignUp
    case fromResetPassword
}

protocol ResetDataForConfirmPasswordProtocol {
    var sid: String { get }
    var title: String { get }
    var description: String { get }
}

struct ResetDataForConfirmPassword: ResetDataForConfirmPasswordProtocol{
    var sid: String
    var title: String = NSLocalizedString("Reset password", comment: "")
    var description = NSLocalizedString("Set new password", comment: "")
}

protocol SignUpDataForConfirmPasswordProtocol {
    var login: String { get }
    var loginType: LoginType { get }
    var sid: String? { get }
    var title: String { get }
    var description: String { get }
}

struct SignUpDataForConfirmPassword: SignUpDataForConfirmPasswordProtocol {
    var login: String
    var loginType: LoginType
    var sid: String?
    var title: String = NSLocalizedString("Sign up", comment: "")
    var description: String = NSLocalizedString("Create password", comment: "")
}

protocol PinCodeViewControllerDelegate : class {
    func pinCodeViewController(_ ctrl: PinCodeViewController, didEnterCode: String, sid: String?)
    func pinCodeViewController(_ ctrl: PinCodeViewController, shouldResendCodeInitial: Bool)
    func pinCodeViewControllerShouldGoBack(_ ctrl: PinCodeViewController)
}

public struct MFADataForPinCode {
    var mfaStep: String
    var mfaIdentifier: String
}

enum MFAStep: String {
    case google
    case email
    case phone_number
}

class PinCodeViewController: KeyboardViewController, KeyboardManagerDelegateViewController {
    
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var enterPinCodeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Enter SMS code", comment: "")
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var cooldownSecondsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var pinCodeTextField: PasswordTextField = {
        let textField = PasswordTextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Code", comment: "")
        return textField
    }()
    
    private lazy var resendCodeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Resend code", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(resendCodePressed), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Check", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        //button.backgroundColor = UIColor(rgb: 0xFA5654)//FA5654
        button.addTarget(self, action: #selector(checkButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var transitionToSignInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Sign in", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(goBackButtonPressed), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: PinCodeViewControllerDelegate?
    var sid: String?
    var cooldownSeconds: Int!{
        didSet {
             self.setCooldowntimer()
        }
    }
    var mfaData: MFADataForPinCode?
    var timer: Timer?
    
    weak var keyboardDelegate: KeyboardManagerDelegate?
    
    init(title: String, description: String, cooldownSeconds: Int = 90, mfaData: MFADataForPinCode? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.cooldownSeconds = cooldownSeconds
        self.titleLabel.text = title
        self.enterPinCodeLabel.text = description
        self.mfaData = mfaData
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.pinCodeViewController(self, shouldResendCodeInitial: true)
    }
    
    @objc func checkButtonPressed(sender: UIButton) {
        self.verifyCode()
    }
    
    @objc func goBackButtonPressed(sender: UIButton) {
        self.delegate?.pinCodeViewControllerShouldGoBack(self)
    }
    
    @objc func resendCodePressed(sender: UIButton) {
        if timer == nil {
            self.delegate?.pinCodeViewController(self, shouldResendCodeInitial: false)
        } else {
            self.showAlert(title: "Error",
                           description: NSLocalizedString("Please, wait: ", comment: "") + self.cooldownSeconds.coolDownType())
        }
    }
    
    private func verifyCode() {
        if let code = pinCodeTextField.text, code.count == 6 {
            delegate?.pinCodeViewController(self, didEnterCode: code, sid: sid)
        } else {
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: NSLocalizedString("The entered code format is incorrect!", comment: ""))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupScrollView()
        self.setupViews()
        self.pinCodeTextField.delegate = self
        self.setCooldowntimer()
        self.setMFAConfigurations()
    }
    
    private func setMFAConfigurations() {
        guard let unwrappedMfaData = self.mfaData else { return }
        if unwrappedMfaData.mfaStep == MFAStep.google.rawValue { // Не показываем таймер и кнопку отправить код
            self.setMFAConfigurationByGoogle(mfaData: unwrappedMfaData)
        } else if unwrappedMfaData.mfaStep == MFAStep.email.rawValue {
            self.setMFAConfigurationByMail(mfaData: unwrappedMfaData)
        } else if unwrappedMfaData.mfaStep == MFAStep.phone_number.rawValue {
            self.setMFAConfigurationByPhone(mfaData: unwrappedMfaData)
        }
    }
    
    private func setMFAConfigurationByGoogle(mfaData: MFADataForPinCode) {
        self.resendCodeButton.isHidden = true
        self.cooldownSecondsLabel.isHidden = true
        let description = NSLocalizedString("Enter the one-time code from", comment: "")
        self.enterPinCodeLabel.text = description + " " + mfaData.mfaIdentifier
    }
    
    private func setMFAConfigurationByMail(mfaData: MFADataForPinCode) {
        let description = NSLocalizedString("Enter the one-time code sent to", comment: "")
        self.enterPinCodeLabel.text = description + " " + mfaData.mfaIdentifier
    }
    
    private func setMFAConfigurationByPhone(mfaData: MFADataForPinCode) {
        let charactersCount = mfaData.mfaIdentifier.count
        let lastTwoDigitOfNumber = mfaData.mfaIdentifier.substring(fromIndex: charactersCount-2)
        let description = NSLocalizedString("Enter the one-time code sent to", comment: "")
        self.enterPinCodeLabel.text = description + "• (•••) ••• ••\(lastTwoDigitOfNumber)"
    }
    
    private func setCooldowntimer() {
        if timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(onTimerFires),
                                              userInfo: nil,
                                              repeats: true)
        }
    }
    
    @objc func onTimerFires() {
        self.cooldownSeconds -= 1
        self.cooldownSecondsLabel.text = self.cooldownSeconds.coolDownType()//"\(self.cooldownSeconds/60):\(self.cooldownSeconds%60)"
        if self.cooldownSeconds <= 0 {
            self.cooldownSecondsLabel.text = ""
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.setupControllerConfiguration()
    }
    
    private func setupControllerConfiguration() {
        let griffon = Griffon.shared
        guard let clientInfo = griffon.config.clientInfo else { return }
        self.setBrandImageFromFileManager(imageView: self.brandImageView, imageName: clientInfo.secret)
        //self.contentView.setBackgroundColor(color: clientInfo.backgroundColor)
        self.setCheckButtonColor(buttonColor: clientInfo.buttonColor)
    }
    
    private func setBrandImageFromFileManager(imageView: UIImageView, imageName: String) {
        let imageService = ImageService()
        guard let uiImage = imageService.read(fileName: imageName) else { return }
        imageView.image = uiImage
    }
    
    private func setCheckButtonColor(buttonColor: ButtonColor) {
        self.checkButton.clipsToBounds = true
        self.checkButton.layer.cornerRadius = 5
        switch buttonColor.type {
        case .gradient:
            self.checkButton.applyGradient(colours: buttonColor.colors, type: .linear)
        case .static_type:
            guard
                let firstColor = buttonColor.colors.first else {
                    return
            }
            self.checkButton.setBackgroundColor(color: firstColor)
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
        
        [brandImageView, titleLabel, enterPinCodeLabel,
         pinCodeTextField, resendCodeButton, checkButton,
         transitionToSignInButton, cooldownSecondsLabel].forEach { (view) in
            self.contentView.addSubview(view)
        }
        
        brandImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        brandImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50).isActive = true
        brandImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4).isActive = true
        brandImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: brandImageView.bottomAnchor, constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        enterPinCodeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        enterPinCodeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        enterPinCodeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        enterPinCodeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        cooldownSecondsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cooldownSecondsLabel.topAnchor.constraint(equalTo: enterPinCodeLabel.bottomAnchor).isActive = true
        cooldownSecondsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        cooldownSecondsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        cooldownSecondsLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        pinCodeTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pinCodeTextField.topAnchor.constraint(equalTo: cooldownSecondsLabel.bottomAnchor).isActive = true
        pinCodeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        pinCodeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        pinCodeTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //resendCodeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        resendCodeButton.topAnchor.constraint(equalTo: pinCodeTextField.bottomAnchor, constant: 20).isActive = true
        resendCodeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        resendCodeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        resendCodeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        checkButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        checkButton.topAnchor.constraint(equalTo: resendCodeButton.bottomAnchor, constant: 10).isActive = true
        checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        checkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        checkButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        transitionToSignInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        transitionToSignInButton.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 10).isActive = true
        transitionToSignInButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

}

extension PinCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.verifyCode()
        return true
    }
}
