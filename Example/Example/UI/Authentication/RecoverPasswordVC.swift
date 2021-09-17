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

protocol RecoverPasswordVCProtocol: BaseViewController, LoadStatable
{
    var actionButtonHandler: ((RecoverPasswordVCProtocol, UIView, RecoverPasswordFormData) -> Void)? { get set }
    var miscButtonHandler: ((RecoverPasswordVCProtocol, UIView) -> Void)? { get set }
}

class RecoverPasswordVC: BaseViewController, RecoverPasswordVCProtocol
{
    // MARK: - Public
    
    /// Form validator, needs to be set before view load
    var formValidator: FormValidatorProtocol?
    var actionButtonHandler: ((RecoverPasswordVCProtocol, UIView, RecoverPasswordFormData) -> Void)?
    var miscButtonHandler: ((RecoverPasswordVCProtocol, UIView) -> Void)?
    
    // LoadStatable
    private var loadState: LoadState = .normal
    
    // MARK: - Outlets
    
    @IBOutlet private weak var usernameTextField: FloatingTitleTextField!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var miscButton: UIButton!
    
    private var activityIndicator: ActivityIndicator?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupUsernameTextField()
        setupActionButton()
        setupMiscButton()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        updateActionButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Setups
    
    private func setupUsernameTextField()
    {
        usernameTextField.placeholder = L10n.Form.Field.Username.placeholder
        usernameTextField.tag = 0
        usernameTextField.delegate = self
        
        if let textValidator = formValidator?.factory.createDefaultValidator(for: usernameTextField)
        {
            formValidator?.addValidator(textValidator, withKey: usernameTextField.tag)
        }
    }
    
    private func setupActionButton()
    {
        actionButton.setupAppearance(config: Button.largeContained)
        actionButton.isEnabled = false
    }
    
    private func setupMiscButton()
    {
        miscButton.setTitleColor(.xsolla_inactiveWhite, for: .normal)
        miscButton.titleLabel?.font = .xolla_button
        miscButton.setTitle(L10n.RecoverPassword.Button.back, for: .normal)
    }
    
    // MARK: - Updates
    
    private func updateActionButton()
    {
        let enabled = formValidator?.validate() ?? false
        actionButton.isEnabled = enabled
        actionButton.setTitle(L10n.RecoverPassword.Button.resetPassword, for: .normal)
    }
    
    // MARK: - Handlers
    
    @IBAction private func onActionButton(_ sender: UIButton)
    {
        let formData = RecoverPasswordFormData(username: usernameTextField.text ?? "")
        actionButtonHandler?(self, sender, formData)
    }
    
    @IBAction private func onMiscButton(_ sender: UIButton)
    {
        miscButtonHandler?(self, sender)
    }
    
    // MARK: - State
    
    private func updateLoadState(_ animated: Bool = false)
    {
        switch loadState
        {
            case .normal, .error: do
            {
                activityIndicator?.removeFromSuperview()
                activityIndicator = nil
                
                updateActionButton()
            }
            
            case .loading(let view): do
            {
                if view === actionButton && activityIndicator == nil
                {
                    actionButton.isEnabled = false
                    actionButton.setTitle(nil, for: .normal)
                    
                    activityIndicator = ActivityIndicator.add(to: self.view, centeredBy: actionButton)
                    activityIndicator?.startAnimating()
                }
            }
        }
    }
}

extension RecoverPasswordVC: LoadStatable
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

extension RecoverPasswordVC: UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        formValidator?.enableValidator(withKey: textField.tag)
        formValidator?.resetValidator(withKey: textField.tag)
        
        updateActionButton()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        formValidator?.resetValidator(withKey: textField.tag)
        
        updateActionButton()
        
        return true
    }
}
