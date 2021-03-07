//
//  SignInViewController.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 17.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

public protocol SignInViewControllerDelegate: class {
    func successfullSignIn(_ ctrl: SignInViewController)
    func successfullSignUp(_ ctrl: SignInViewController)
}

public class SignInViewController: KeyboardViewController, KeyboardManagerDelegateViewController {

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
    
    private lazy var signInLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Sign in", comment: "")
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    private lazy var signTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Login with email address or phone number", comment: "")
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
    
    private lazy var passwordTextField: PasswordTextField = {
        let textField = PasswordTextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Password", comment: "")
        return textField
    }()
    
    private lazy var forgetPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Forgot your password?", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(forgetPasswordPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Sign in now", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var thirdpClientButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("SIGN IN WITH FORTE", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.leftImage(image: UIImage(named: "forte")!, renderMode: .alwaysOriginal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(signInWithForte), for: .touchUpInside)
        return button
    }()
    
    private lazy var transitionToSignUpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Sign up", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(transitionToSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func signInWithForte(sender: UIButton) {
        guard let forte = self.forteClient else { return }
        let clientId = Griffon.shared.config.clientId
        guard let url = Foundation.URL(string: "https://griffon.dar-dev.zone/api/v1/oauth/authorize?client_id=\(clientId)&provider=\(forte.provider)&response_type=code") else { return }
        let webVC = WebViewController(url: url)
        webVC.thirdPClientDelegate = self
        self.present(webVC, animated: true)
    }
    
    @objc func forgetPasswordPressed(sender: UIButton) {
        let vc = ResetPasswordViewController()
        self.present(vc, animated: true)
    }
    
    @objc func signInButtonPressed(sender: UIButton) {
        self.signInNow()
    }
    
    private func signInNow() {
        if areFieldsEmpty() {
            self.showSpinner(onView: contentView)
            guard let login = loginTextField.text, let password = passwordTextField.text else {
                return
            }
            self.signInRequest(login: login.convertPhoneType(), password: password)
        } else {
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: NSLocalizedString("Fill in all the fields", comment: ""))
        }
    }
    
    private func signInRequest(login: String, password: String) {
        NetworkManager.instance.signIn(username: login,
                               password: password,
                               success: { [weak self] (result) in
            guard let self = self else { return }
            self.griffon.signInModel = result
            self.getUserProfiles {
                self.removeSpinner()
                self.showAlert(title: NSLocalizedString("Successfull authorize", comment: ""),
                                description: result.accessToken, completion: { [weak self] (alert) in
                                guard let self = self else { return}
                                self.delegate?.successfullSignIn(self)
                })
            }
            }, successMFA: { [weak self] (result) in
                guard let self = self else { return }
                self.mfaResponse = result
                print("Result :\(result)")
                self.removeSpinner()
                self.verifyMFACode(cooldownSeconds: result.addInfo, mfaStep: result.mfaStep, mfaIdentifier: result.mfaIdentifier)
            }, failure: { (error) in
                self.removeSpinner()
                self.showAlert(title: NSLocalizedString("Error", comment: ""),
                               description: (error as NSError).domain)
        })
    }
    
    private func verifyMFACode(cooldownSeconds: String, mfaStep: String, mfaIdentifier: String) {
        guard let cooldownSecondsInt = Int(cooldownSeconds) else { return }
        let mfaData = MFADataForPinCode.init(mfaStep: mfaStep, mfaIdentifier: mfaIdentifier)
        let vc = PinCodeViewController(title: NSLocalizedString("Multi-Factor Authentication", comment: ""), description: "",
                                       cooldownSeconds: cooldownSecondsInt,
                                       mfaData: mfaData)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    private func getUserProfiles(completion: @escaping ()->()) {
        NetworkManager.instance.getUserProfiles(success: { [weak self] (result) in
            guard let self = self else { return }
            self.griffon.userProfiles = result
            completion()
        }) { (error) in
            self.showAlert(title: "Error", description: "Error in getting userProfiles data!")
            completion()
        }
    }
    
    @objc func transitionToSignUp(sender: UIButton) {
        let vc = SignUpViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
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
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public weak var delegate: SignInViewControllerDelegate?
    let griffon = Griffon.shared
    
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    var forteClient: ThirdpClientResponseModel?
    var mfaResponse: SignInMFAResponseModel?
    var signInAndSignUpBetweenConstraint: NSLayoutConstraint?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = .white
        self.setupScrollView()
        self.showSpinner(onView: contentView)
        self.setupViews()
        self.loginTextField.delegate = self
        self.passwordTextField.delegate = self
        self.getClientInfoData()
    }
    
    private func setupControllerConfigurations() {
        guard let clientInfo = griffon.config.clientInfo else { return }
        self.brandImageView.downloaded(from: clientInfo.logoImage, completion: { image in
            self.saveBrandImageInFileManager(image: image, fileName: clientInfo.secret)
        })
        //self.contentView.setBackgroundColor(color: clientInfo.backgroundColor)
        self.setSignInButtonColor(buttonColor: clientInfo.buttonColor)
    }
    
    private func saveBrandImageInFileManager(image: UIImage?, fileName: String) {
        guard let strongImage = image else { return }
        let imageService = ImageService()
        do {
            try imageService.write(fileName: fileName, image: strongImage)
        } catch let error {
            print("Error in saving image: \(error)")
        }
    }
    
    private func setSignInButtonColor(buttonColor: ButtonColor) {
        switch buttonColor.type {
        case .gradient:
            signInButton.applyGradient(colours: buttonColor.colors, type: .linear)
        case .static_type:
             guard
                let firstColor = buttonColor.colors.first else {
                    return
             }
             self.signInButton.setBackgroundColor(color: firstColor)
        }
    }
    
    private func getClientInfoData() {
        NetworkManager.instance.getClientInfo(success: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.griffon.config.clientInfo = result
            strongSelf.get3rdpClients()
            strongSelf.setupControllerConfigurations()
        }) { (error) in
            self.removeSpinner()
            print("Error in get client info data")
        }
    }
    
    private func get3rdpClients() {
        NetworkManager.instance.get3rdpClients(success: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.griffon.thirdpClients = result
            strongSelf.setupThirdpClientsButton()
            strongSelf.removeSpinner()
        }) { (error) in
            self.removeSpinner()
        }
    }
        
    var vSpinner : UIView?
    var keyboardDelegate: KeyboardManagerDelegate?
    
    private func areFieldsEmpty() -> Bool {
        var value = false
        (self.loginTextField.text != nil && self.passwordTextField.text != nil) ? (value = true) : (value = false)
        return value
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
        [brandImageView, signInLabel, signTypeLabel,
         loginTextField, passwordTextField, forgetPasswordButton,
         signInButton, transitionToSignUpButton ].forEach { (view) in
            self.contentView.addSubview(view)
        }
        
        brandImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        brandImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        brandImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4).isActive = true
        brandImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2).isActive = true
                
        signInLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        signInLabel.topAnchor.constraint(equalTo: brandImageView.bottomAnchor, constant: 0).isActive = true
        signInLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        signInLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        signTypeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        signTypeLabel.topAnchor.constraint(equalTo: signInLabel.bottomAnchor, constant: 5).isActive = true
        signTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        signTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        loginTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loginTextField.topAnchor.constraint(equalTo: signTypeLabel.bottomAnchor, constant: 10).isActive = true
        loginTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        loginTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        loginTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        passwordTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 5).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        forgetPasswordButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor).isActive = true
        forgetPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 5).isActive = true
        forgetPasswordButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
                
        transitionToSignUpButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        transitionToSignUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        transitionToSignUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        transitionToSignUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true

        self.signInAndSignUpBetweenConstraint = transitionToSignUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 15)
        NSLayoutConstraint.activate([self.signInAndSignUpBetweenConstraint!])
        
        signInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let forte = griffon.thirdpClients.filter{$0.provider == "forte"}
        if !forte.isEmpty {
            self.forteClient = forte.first!
        }
    }
    
    private func setupThirdpClientsButton() {
        let forte = griffon.thirdpClients.filter{$0.provider == "forte"}
        if !forte.isEmpty {
            self.forteClient = forte.first!
            self.contentView.addSubview(thirdpClientButton)
            self.signInAndSignUpBetweenConstraint?.isActive = false
            self.signInAndSignUpBetweenConstraint = transitionToSignUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 64)
            NSLayoutConstraint.activate([self.signInAndSignUpBetweenConstraint!])
            transitionToSignUpButton.layoutIfNeeded()
            thirdpClientButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            thirdpClientButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
            thirdpClientButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
            thirdpClientButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            thirdpClientButton.bottomAnchor.constraint(equalTo: transitionToSignUpButton.topAnchor, constant: -10).isActive = true
            thirdpClientButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 10).isActive = true
        }
    }
}

extension SignInViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .gray)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.vSpinner?.removeFromSuperview()
            strongSelf.vSpinner = nil
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            self.signInNow()
        }
        return true
    }
}

extension SignInViewController: SignUpViewControllerDelegate {
    func signUpViewControllerSuccess(_ ctrl: SignUpViewController) {
        ctrl.dismiss(animated: true) {
            self.delegate?.successfullSignUp(self)
        }
    }
    
    func signUpViewControllerShouldGoBack(_ ctrl: SignUpViewController) {
        ctrl.dismiss(animated: true, completion: nil)
    }
}

extension SignInViewController: PinCodeViewControllerDelegate {
    func pinCodeViewController(_ ctrl: PinCodeViewController, didEnterCode: String, sid: String?) {
        print("From PincodeViewController: code - \(didEnterCode), sid - \(sid ?? "nil")")
        guard let mfaSid = self.mfaResponse?.sid else { return }
        NetworkManager.instance.sendMFACode(sid: mfaSid, code: didEnterCode, success: { [weak self] (result) in
            print("Successfull result after mfa: \(result)")
            guard let self = self else { return }
            ctrl.dismiss(animated: true) {
                self.griffon.signInModel = result
                self.showAlert(title: NSLocalizedString("Successfull authorize", comment: ""),
                               description: result.accessToken, completion: { [weak self] (alert) in
                                guard let self = self else { return}
                                self.delegate?.successfullSignIn(self)
                })
            }
        }) { (error) in
            let errorDomain = (error as NSError).domain
            ctrl.showAlert(title: NSLocalizedString("Error", comment: ""),
                           description: errorDomain)
            print("Error : \(errorDomain)")
        }
    }
    
    func pinCodeViewController(_ ctrl: PinCodeViewController, shouldResendCodeInitial: Bool) {
        print("From PincodeViewController tapped to resend code")
        if !shouldResendCodeInitial {
            guard let mfaSid = self.mfaResponse?.sid else { return }
            NetworkManager.instance.resendMFACode(sid: mfaSid, success: { [weak self] (result) in
                guard let self = self else { return }
                self.mfaResponse = result
                ctrl.showAlert(title: NSLocalizedString("Successfull", comment: ""),
                               description: NSLocalizedString("Successfull resend code", comment: ""))
                ctrl.cooldownSeconds = Int(result.addInfo) ?? 90
            }) { (error) in
                ctrl.showAlert(title: NSLocalizedString("Error", comment: ""), description: (error as NSError).domain)
            }
        }
    }
    
    func pinCodeViewControllerShouldGoBack(_ ctrl: PinCodeViewController) {
        ctrl.dismiss(animated: true, completion: nil)
    }
}

extension SignInViewController: WebViewThirdPClientDelegate {
    func successAuthorize(state: String, code: String) {
        print("Send request for getting tokens with state: \(state), code: \(code)")
        NetworkManager.instance.authBy3rdpClient(sid: state, code: code, success: { [weak self] result in
            guard let self = self else { return }
            self.griffon.signInModel = result
            self.showAlert(title: NSLocalizedString("Successfull authorize", comment: ""),
                           description: result.accessToken, completion: { [weak self] (alert) in
                            guard let self = self else { return}
                            self.delegate?.successfullSignIn(self)
            })
        }) { (error) in
            self.showAlert(title: NSLocalizedString("Error", comment: ""),
                                   description: (error as NSError).domain)
        }
    }
    
    func failureAuthorize() {
        print("Show error in authorize")
    }
}



