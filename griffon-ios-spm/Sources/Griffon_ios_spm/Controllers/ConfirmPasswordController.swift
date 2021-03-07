//
//  ConfirmPasswordController.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 07.09.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

public enum ConfirmVCInitType: String {
    case fromSignUp
    case fromResetPassword
}

protocol ConfirmPasswordControllerDelegate: class {
    func confirmPasswordControllerShouldGoBack(_ ctrl: ConfirmPasswordController)
    func confirmPasswordControllerSuccess(_ ctrl: ConfirmPasswordController)
}

class ConfirmPasswordController: KeyboardViewController, KeyboardManagerDelegateViewController  {

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
        label.text = NSLocalizedString("Sign up", comment: "")
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Login with email address or phone number", comment: "")
        label.numberOfLines = 0
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    
    private lazy var passwordTextField: PasswordTextField = {
        let textField = PasswordTextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Password", comment: "")
        return textField
    }()
    
    private lazy var confirmPasswordTextField: PasswordTextField = {
        let textField = PasswordTextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Confirm password", comment: "")
        return textField
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
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(transitionToSignInVC), for: .touchUpInside)
        return button
    }()
        
    let griffon = Griffon.shared
    
    var resetPasswordData: ResetDataForConfirmPassword?
    var signUpData: SignUpDataForConfirmPasswordProtocol?
    var initType: ConfirmVCInitType?
    weak var delegate: ConfirmPasswordControllerDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(signUpData: SignUpDataForConfirmPasswordProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.signUpData = signUpData
        self.initType = .fromSignUp
    }
    
    init(resetData: ResetDataForConfirmPassword) {
        super.init(nibName: nil, bundle: nil)
        self.resetPasswordData = resetData
        self.initType = .fromResetPassword
    }
    
    @objc func nextButtonPressed() {
        compareAndRegisterPasswords()
    }
    
    private func compareAndRegisterPasswords() {
        if isPasswordsEqual() {
            switch self.initType {
            case .fromSignUp:
                signUpPasswordSet()
            case .fromResetPassword:
                newPasswordSet()
            case .none:
                break
            }
        } else {
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: NSLocalizedString("Enter the same passwords!", comment: ""))
        }
    }
    
    private func signUpPasswordSet() {
        guard let login = self.signUpData?.login else { return }
        guard let password = passwordTextField.text else {
            self.showAlert(title: NSLocalizedString("The entered code format is incorrect!", comment: ""),
                           description: NSLocalizedString("Enter login and password!", comment: ""))
            return
        }
        self.sendRequestForRegister(login: login, password: password)
    }
    
    private func newPasswordSet() {
        guard
            let password = passwordTextField.text,
            let sid = self.resetPasswordData?.sid else {
                return
        }
        NetworkManager.instance.setNewPassword(sid: sid,
                                               newPassword: password,
                                               success: { (result) in
            self.showAlert(title: NSLocalizedString("Сongratulations", comment: ""),
                           description: NSLocalizedString("You have successfully reset password!", comment: ""),
                           completion: { [weak self] (alert) in
                guard let self = self else { return }
                self.delegate?.confirmPasswordControllerSuccess(self)
            })
        }) { (error) in
            let errorDomain = (error as NSError).domain
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: errorDomain)
        }
    }
    
    @objc func transitionToSignInVC() {
        self.delegate?.confirmPasswordControllerShouldGoBack(self)
    }
    
    private func sendRequestForRegister(login: String, password: String) {
        guard let signUpData = self.signUpData else { return }
        if signUpData.loginType == .email {
            self.registerByMail(login: login, password: password)
        } else if signUpData.loginType == .phone_number {
            self.registerByPhone(password: password)
        }
    }
    
    private func registerByMail(login: String, password: String) {
        NetworkManager.instance.signUpWithMail(mail: login, password: password, success: { (result) in
            self.griffon.signUpModel = result
            self.showAlert(title: NSLocalizedString("Сongratulations", comment: ""),
                           description: NSLocalizedString("You have successfully registered by mail!", comment: ""),
                           completion: { [weak self] (alert) in
                guard let self = self else { return }
                self.delegate?.confirmPasswordControllerSuccess(self)
            })
        }) { (error) in
            let errorDomain = (error as NSError).domain
            print("Error in register by mail! Error: \(errorDomain)")
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: errorDomain)
        }
    }
    
    private func registerByPhone(password: String) {
        guard let sid = self.signUpData?.sid else { return }
        NetworkManager.instance.registerWithPhone(sid: sid, password: password, success: { (result) in
            self.griffon.signUpModel = result
            self.showAlert(title: NSLocalizedString("Сongratulations", comment: ""),
                           description: NSLocalizedString("You have successfully registered by phone!", comment: ""),
                           completion: { [weak self] (alert) in
                guard let self = self else { return }
                self.delegate?.confirmPasswordControllerSuccess(self)
            })
        }) { (error) in
            let errorDomain = (error as NSError).domain
            print("Error in register by phone! Error: \(errorDomain)")
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: errorDomain)
        }
    }
    
    func isPasswordsEqual() -> Bool {
        guard let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text else {
            return false
        }
        var value = false
        (password == confirmPassword) ? (value = true) : (value = false)
        return value
    }
    
    weak var keyboardDelegate: KeyboardManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScrollView()
        self.setupViews()
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupControllerConfiguration()
    }
    
    private func setupControllerConfiguration() {
        guard let clientInfo = griffon.config.clientInfo else { return }
        self.setBrandImageFromFileManager(imageView: self.brandImageView, imageName: clientInfo.secret)
        self.view.backgroundColor = .white
        self.setCheckButtonColor(buttonColor: clientInfo.buttonColor)
        switch initType {
        case .fromResetPassword:
            self.titleLabel.text = self.resetPasswordData?.title
            self.descriptionLabel.text = self.resetPasswordData?.description
        case .fromSignUp:
            self.titleLabel.text = self.signUpData?.title
            self.descriptionLabel.text = self.signUpData?.description
        case .none:
            break
        }
    }
    
    private func setBrandImageFromFileManager(imageView: UIImageView, imageName: String) {
        let imageService = ImageService()
        guard let uiImage = imageService.read(fileName: imageName) else { return }
        imageView.image = uiImage
    }
    
    private func setCheckButtonColor(buttonColor: ButtonColor) {
        self.nextButton.clipsToBounds = true
        self.nextButton.layer.cornerRadius = 5
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
        [brandImageView, titleLabel, descriptionLabel,
         passwordTextField, confirmPasswordTextField,
         nextButton, signInButton].forEach { (view) in
            self.contentView.addSubview(view)
        }
        
        brandImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        brandImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        brandImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4).isActive = true
        brandImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: brandImageView.bottomAnchor, constant: 15).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        passwordTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        confirmPasswordTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 5).isActive = true
        confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        nextButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        signInButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 15).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}

extension ConfirmPasswordController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.compareAndRegisterPasswords()
        return true
    }
}
