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

protocol SignupVCProtocol: BaseViewController, LoadStatable
{
    var signupRequestHandler: ((SignupVCProtocol, UIView, SignupFormData) -> Void)? { get set }
    var privacyPolicyRequestHandler: (() -> Void)? { get set }
}

class SignupVC: BaseViewController, SignupVCProtocol
{
    // SignupVCProtocol
    var signupRequestHandler: ((SignupVCProtocol, UIView, SignupFormData) -> Void)?
    var privacyPolicyRequestHandler: (() -> Void)?
    
    /// Form validator, needs to be set before view load
    var formValidator: FormValidatorProtocol!
    
    // LoadStatable
    private var loadState: LoadState = .normal
    
    @IBOutlet private weak var usernameTextField: FloatingTitleTextField!
    @IBOutlet private weak var emailTextField: FloatingTitleTextField!
    @IBOutlet private weak var passwordTextField: FloatingTitleTextField!
    @IBOutlet private weak var passwordConfirmTextField: FloatingTitleTextField!
    
    @IBOutlet private weak var signupButton: Button!

    @IBOutlet private weak var privacyPolicyLabel: UILabel!

    private let textColor = UIColor.xsolla_white
    private let activeColor = UIColor.xsolla_magenta
    private let normalColor = UIColor.xsolla_transparentSlateGrey
    
    private func performPrivacyPolicyRequest()
    {
        logger.event(.common, domain: .example) { "Privacy policy pressed" }
        privacyPolicyRequestHandler?()
    }
    
    private func performSignup()
    {
        logger.event(.common, domain: .example) { "Signup pressed" }
        let formData = SignupFormData(username: usernameTextField.text ?? "",
                                      email: emailTextField.text ?? "",
                                      password: passwordTextField.text ?? "")
        signupRequestHandler?(self, signupButton, formData)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard formValidator != nil else { fatalError("Form validator is not set") }
        
        setupInputFields()
        setupSignupButton()
        setupPrivacyPolicyButton()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        updateSignupButton()
    }
    
    // MARK: - Setup UI
    
    private func setupInputFields()
    {
        // Username
        usernameTextField.placeholder = L10n.Form.Field.Username.placeholder
        usernameTextField.tag = 1
        usernameTextField.delegate = self
        usernameTextField.configureTextFieldDefaults()
        usernameTextField.configureTextField { textField in textField.keyboardType = .emailAddress }

        formValidator.addValidator(formValidator.factory.createDefaultValidator(for: usernameTextField),
                                   withKey: usernameTextField.tag)
        
        // Email
        emailTextField.placeholder = L10n.Form.Field.Email.placeholder
        emailTextField.tag = 2
        emailTextField.delegate = self
        emailTextField.configureTextFieldDefaults()
        emailTextField.configureTextField { textField in textField.keyboardType = .emailAddress }

        formValidator.addValidator(formValidator.factory.createDefaultValidator(for: emailTextField),
                                   withKey: emailTextField.tag)
        
        // Password
        passwordTextField.placeholder = L10n.Form.Field.Password.placeholder
        passwordTextField.secure = true
        passwordTextField.set(hintText: L10n.Form.Field.Password.hint)
        passwordTextField.tag = 3
        passwordTextField.delegate = self
        passwordTextField.configureTextFieldDefaults()
        
        formValidator.addValidator(formValidator.factory.createPasswordValidator(for: passwordTextField),
                                   withKey: passwordTextField.tag)
        
        // Password confirm
        passwordConfirmTextField.placeholder = L10n.Form.Field.ConfirmPassword.placeholder
        passwordConfirmTextField.secure = true
        passwordConfirmTextField.tag = 4
        passwordConfirmTextField.delegate = self
        passwordConfirmTextField.configureTextFieldDefaults()

        formValidator.addValidator(formValidator.factory.createPasswordValidator(for: passwordConfirmTextField),
                                   withKey: passwordConfirmTextField.tag)
    }
    
    private func setupSignupButton()
    {
        signupButton.setupAppearance(config: Button.largeContained)
        signupButton.isEnabled = false
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

    private func extraFormValidation() -> Bool
    {
        if passwordTextField.text != passwordConfirmTextField.text { return false }

        return true
    }

    private func updateSignupButton()
    {
        let enabled = formValidator.validate() && extraFormValidation()

        if signupButton.isEnabled != enabled { signupButton.isEnabled = enabled }
        
        signupButton.setTitle(L10n.Auth.Button.signup.capitalized, for: .normal)
    }
    
    // MARK: - Button Handlers
    
    @IBAction private func onSignupButton(_ sender: UIButton)
    {
        performSignup()
    }
    
    // MARK: - State
    
    func updateLoadState(_ animated: Bool = false)
    {
        switch loadState
        {
            case .normal, .error: do
            {
                hideActivityIndicator()
                
                updateSignupButton()
            }
            
            case .loading(let view): do
            {
                signupButton.isEnabled = false
                
                if view === signupButton
                {
                    signupButton.setTitle(nil, for: .normal)
                    showActivityIndicator(for: signupButton)
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

extension SignupVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField.tag
        {
            case usernameTextField.tag: _ = emailTextField.becomeFirstResponder()
            case emailTextField.tag: _ = passwordTextField.becomeFirstResponder()
            case passwordTextField.tag: _ = passwordConfirmTextField.becomeFirstResponder()
            case passwordConfirmTextField.tag: _ = usernameTextField.becomeFirstResponder()

            default: break
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        formValidator.enableValidator(withKey: textField.tag)
        formValidator.resetValidator(withKey: textField.tag)
        formValidator.enableErrorsForValidator(withKey: textField.tag)
        
        updateSignupButton()
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

        updateSignupButton()
        
        return false
    }
}

extension SignupVC: LoadStatable
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
