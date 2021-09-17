// Copyright 2021-present Xsolla (USA), Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at q
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing and permissions and

import UIKit

protocol LoginVCProtocol: BaseViewController, LoadStatable
{
    var loginRequestHandler: ((LoginVCProtocol, UIView, LoginFormData) -> Void)? { get set }
    var authenticationOptionsRequestHandler: ((LoginVCProtocol, UIView) -> Void)? { get set }
    var socialNetworkLoginRequestHandler: ((LoginVCProtocol, SocialNetwork) -> Void)? { get set }
    var moreSocialNetworksRequestHandler: ((LoginVCProtocol) -> Void)? { get set }
    var privacyPolicyRequestHandler: (() -> Void)? { get set }
    var passwordRecoveryRequestHandler: (() -> Void)? { get set }
}

class LoginVC: BaseViewController, LoginVCProtocol
{
    // LoginVCProtocol
    var loginRequestHandler: ((LoginVCProtocol, UIView, LoginFormData) -> Void)?
    var authenticationOptionsRequestHandler: ((LoginVCProtocol, UIView) -> Void)?
    var socialNetworkLoginRequestHandler: ((LoginVCProtocol, SocialNetwork) -> Void)?
    var moreSocialNetworksRequestHandler: ((LoginVCProtocol) -> Void)?
    var privacyPolicyRequestHandler: (() -> Void)?
    var passwordRecoveryRequestHandler: (() -> Void)?

    /// Form validator, needs to be set before view load
    var formValidator: FormValidatorProtocol!
    
    // LoadStatable
    private var loadState: LoadState = .normal
    
    @IBOutlet private weak var usernameTextField: FloatingTitleTextField!
    @IBOutlet private weak var passwordTextField: FloatingTitleTextField!
    
    @IBOutlet private weak var passwordRecoverButton: UIButton!
    @IBOutlet private weak var loginButton: Button!
    @IBOutlet private weak var authenticationOptionsButton: Button!
    @IBOutlet private weak var googleButton: Button!
    @IBOutlet private weak var facebookButton: Button!
    @IBOutlet private weak var baiduButton: Button!
    @IBOutlet private weak var moreButton: Button!
    
    @IBOutlet private weak var privacyPolicyLabel: UILabel!
    
    private let textColor = UIColor.xsolla_white
    private let activeColor = UIColor.xsolla_magenta
    private let normalColor = UIColor.xsolla_transparentSlateGrey
    
    private func performSocialNetworkLogin(_ network: SocialNetwork)
    {
        logger.event(.common, domain: .example) { "Login with \(network) pressed" }
        socialNetworkLoginRequestHandler?(self, network)
    }
    
    private func performPrivacyPolicyRequest()
    {
        logger.event(.common, domain: .example) { "Privacy policy pressed" }
        privacyPolicyRequestHandler?()
    }
    
    private func performLogin()
    {
        logger.event(.common, domain: .example) { "Login pressed" }
        let formData = LoginFormData(username: usernameTextField.text ?? "",
                                     password: passwordTextField.text ?? "")
        
        loginRequestHandler?(self, loginButton, formData)
    }
    
    private func showAuthenticationOptions()
    {
        logger.event(.common, domain: .example) { "Show authentication options pressed" }
        authenticationOptionsRequestHandler?(self, authenticationOptionsButton)
    }
    
    private func performPasswordRecovery()
    {
        logger.event(.common, domain: .example) { "Password recovery pressed" }
        passwordRecoveryRequestHandler?()
    }
    
    private func performShowMoreSocialNetworks()
    {
        logger.event(.common, domain: .example) { "Show more social networks pressed" }
        moreSocialNetworksRequestHandler?(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        guard formValidator != nil else { fatalError("Form validator is not set") }
        
        setupInputFields()
        setupLoginButton()
        setupDemoUserLoginButton()
        setupPasswordRecoverButton()
        setupSocialButtons()
        setupPrivacyPolicyButton()
    }
        
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    
        updateLoginButton()
        updateAuthenticationOptionsButton()
    }
    
    // MARK: - Setup UI
    
    private func setupInputFields()
    {
        setupUsernameTextField()
        setupPasswordTextField()
    }
    
    private func setupUsernameTextField()
    {
        usernameTextField.placeholder = L10n.Form.Field.Username.placeholder
        usernameTextField.tag = 1
        usernameTextField.delegate = self
        usernameTextField.configureTextFieldDefaults()
        usernameTextField.configureTextField { textField in textField.keyboardType = .emailAddress }

        formValidator.addValidator(formValidator.factory.createDefaultValidator(for: usernameTextField),
                                   withKey: usernameTextField.tag)
    }
    
    private func setupPasswordTextField()
    {
        passwordTextField.placeholder = L10n.Form.Field.Password.placeholder
        passwordTextField.secure = true
        passwordTextField.tag = 2
        passwordTextField.delegate = self
        passwordTextField.configureTextFieldDefaults()
        
        formValidator.addValidator(formValidator.factory.createPasswordValidator(for: passwordTextField),
                                   withKey: passwordTextField.tag)
    }
    
    private func setupLoginButton()
    {
        loginButton.setupAppearance(config: Button.largeContained)
        loginButton.isEnabled = false
    }
    
    private func setupDemoUserLoginButton()
    {
        authenticationOptionsButton.setupAppearance(config: Button.largeOutlined)
    }
    
    private func setupPasswordRecoverButton()
    {
        passwordRecoverButton.setTitleColor(.xsolla_transparentSlateGrey, for: .normal)
        passwordRecoverButton.titleLabel?.font = .xolla_link
        passwordRecoverButton.setTitle(L10n.Auth.Button.recoverPassword, for: .normal)
    }
    
    private func setupSocialButtons()
    {
        googleButton.setupAppearance(config: Button.largeOutlined)
        facebookButton.setupAppearance(config: Button.largeOutlined)
        baiduButton.setupAppearance(config: Button.largeOutlined)
        moreButton.setupAppearance(config: Button.largeOutlined)

        googleButton.setImage(Asset.Images.socialGoogleIcon.tinted(.xsolla_inactiveWhite), for: .normal)
        facebookButton.setImage(Asset.Images.socialFacebookIcon.tinted(.xsolla_inactiveWhite), for: .normal)
        baiduButton.setImage(Asset.Images.socialBaiduIcon.tinted(.xsolla_inactiveWhite), for: .normal)
        moreButton.setImage(Asset.Images.socialMoreIcon.tinted(.xsolla_inactiveWhite), for: .normal)
    }
    
    private func setupPrivacyPolicyButton()
    {
        let text = L10n.Auth.Button.PrivacyPolicy.text(L10n.Auth.Button.PrivacyPolicy.linkTitle)
        let attrText = text.attributedMutable(.link, color: .xsolla_inactiveWhite)

        let attrs: Attributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        attrText.addAttributes(attrs, toSubstring: L10n.Auth.Button.PrivacyPolicy.linkTitle)
        
        privacyPolicyLabel.numberOfLines = 0
        privacyPolicyLabel.attributedText = attrText
        privacyPolicyLabel.addTapHandler { [unowned self] in self.performPrivacyPolicyRequest() }
        privacyPolicyLabel.isUserInteractionEnabled = true
    }
    
    // MARK: - Updates
    
    private func updateLoginButton()
    {
        let enabled = formValidator.validate()

        if loginButton.isEnabled != enabled { loginButton.isEnabled = enabled }

        let color: UIColor = enabled ? .xsolla_white : .xsolla_inactiveWhite
        let attributedTitle = L10n.Auth.Button.login.attributed(.button, color: color)
        loginButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private func updateAuthenticationOptionsButton()
    {
        authenticationOptionsButton.isEnabled = true
        let attributedTitle = L10n.Auth.Button.authenticationOptions.attributed(.button, color: .xsolla_inactiveWhite)
        authenticationOptionsButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // MARK: - Button Handlers
    
    @IBAction private func onPasswordRecoverButton(_ sender: UIButton)
    {
        performPasswordRecovery()
    }
    
    @IBAction private func onLoginButton(_ sender: UIButton)
    {
        performLogin()
    }
    
    @IBAction private func onDemoUserLoginButton(_ sender: UIButton)
    {
        showAuthenticationOptions()
    }
    
    @IBAction private func onGoogleButton(_ sender: Button)
    {
        performSocialNetworkLogin(.google)
    }
    
    @IBAction private func onFacebookButton(_ sender: Button)
    {
        performSocialNetworkLogin(.facebook)
    }
    
    @IBAction private func onBaiduButton(_ sender: Button)
    {
        performSocialNetworkLogin(.baidu)
    }
    
    @IBAction private func onMoreButton(_ sender: Button)
    {
        performShowMoreSocialNetworks()
    }
    
    // MARK: - State
    
    func updateLoadState(_ animated: Bool = false)
    {
        switch loadState
        {
            case .normal, .error: do
            {
                hideActivityIndicator()
                
                updateLoginButton()
                updateAuthenticationOptionsButton()
            }
            
            case .loading(let view): do
            {
                loginButton.isEnabled = false
                authenticationOptionsButton.isEnabled = false
                
                if view === loginButton
                {
                    loginButton.setTitle(nil, for: .normal)
                    showActivityIndicator(for: loginButton)
                }
                
                if view === authenticationOptionsButton
                {
                    authenticationOptionsButton.setTitle(nil, for: .normal)
                    showActivityIndicator(for: authenticationOptionsButton)
                }
            }
        }
    }
    
    var activityIndicator: ActivityIndicator?
    
    private func showActivityIndicator(for view: UIView)
    {
        if activityIndicator == nil
        {
            if let superview = view.superview
            {
                activityIndicator = ActivityIndicator.add(to: superview, centeredBy: view)
            }
        }
        
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    private func hideActivityIndicator()
    {
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
}

extension LoginVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField.tag
        {
            case usernameTextField.tag: _ = passwordTextField.becomeFirstResponder()
            case passwordTextField.tag: _ = usernameTextField.becomeFirstResponder()

            default: break
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        formValidator.enableValidator(withKey: textField.tag)
        formValidator.resetValidator(withKey: textField.tag)
        formValidator.enableErrorsForValidator(withKey: textField.tag)
        
        updateLoginButton()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        formValidator.enableValidator(withKey: textField.tag)
        formValidator.resetValidator(withKey: textField.tag)

        guard let text = textField.text, let textRange = Range(range, in: text) else { return true }

        let updatedText = text.replacingCharacters(in: textRange, with: string)
        textField.text = updatedText

        updateLoginButton()
        
        return false
    }
}

extension LoginVC: LoadStatable
{
    func getState() -> LoadState
    {
        loadState
    }

    func setState(_ state: LoadState, animated: Bool)
    {
        loadState = state
        updateLoadState(animated)
    }
}
