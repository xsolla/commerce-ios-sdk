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

protocol UpgradeAccountVCProtocol: BaseViewController, LoadStatable
{
    var model: UpgradeAccountVC.Model { get }
    var actionRequestHandler: ((UpgradeAccountVCProtocol, UIView) -> Void)? { get set }
}

class UpgradeAccountVC: BaseViewController, UpgradeAccountVCProtocol
{
    var actionRequestHandler: ((UpgradeAccountVCProtocol, UIView) -> Void)?

    var loadState: LoadState = .normal
    var activityVC: ActivityIndicatingViewController?
    var model = Model()

    @IBOutlet private weak var usernameTextField: FloatingTitleTextField!
    @IBOutlet private weak var emailTextField: FloatingTitleTextField!
    @IBOutlet private weak var passwordTextField: FloatingTitleTextField!
    @IBOutlet private weak var confirmPasswordTextField: FloatingTitleTextField!
    @IBOutlet private weak var actionButton: Button!

    override var navigationBarIsHidden: Bool? { false }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        title = L10n.Profile.Button.addUsernamePassword

        setupTextFields()
        setupActionButton()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        updateTextFields()
        updateActionButton()
    }

    func setupTextFields()
    {
        usernameTextField.tag = 1
        emailTextField.tag = 2
        passwordTextField.tag = 3
        confirmPasswordTextField.tag = 4

        usernameTextField.placeholder = L10n.Form.Field.Username.placeholder
        emailTextField.placeholder = L10n.Form.Field.Email.placeholder
        passwordTextField.placeholder = L10n.Form.Field.Password.placeholder
        confirmPasswordTextField.placeholder = L10n.Form.Field.ConfirmPassword.placeholder

        passwordTextField.secure = true
        confirmPasswordTextField.secure = true

        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        usernameTextField.configureTextFieldDefaults()
        emailTextField.configureTextFieldDefaults()
        emailTextField.configureTextField { textField in textField.keyboardType = .emailAddress }
        passwordTextField.configureTextFieldDefaults()
        confirmPasswordTextField.configureTextFieldDefaults()

        passwordTextField.set(hintText: L10n.Form.Field.Password.hint)
    }

    func setupActionButton()
    {
        actionButton.setupAppearance(config: Button.largeContained)
        actionButton.setTitle(L10n.Profile.Button.save, attributes: Style.button.attributes(withColor: .xsolla_white))
        actionButton.setTitle(L10n.Profile.Button.save,
                              attributes: Style.button.attributes(withColor: .xsolla_onSurfaceMedium),
                              for: .disabled)
    }

    func updateTextFields()
    {
        usernameTextField.set(text: model.username)
        emailTextField.set(text: model.email)
        passwordTextField.set(text: model.password)
        confirmPasswordTextField.set(text: model.confirmPassword)
    }

    func updateActionButton()
    {
        actionButton.isEnabled = validate()
    }

    func validate() -> Bool
    {
        if model.username.count < 2 { return false }
        if model.email.count < 2 { return false }
        if model.password.count < 2 { return false }
        if model.confirmPassword.count < 2 { return false }

        if model.password != model.confirmPassword { return false }

        return true
    }

    @IBAction private func onActionButton(_ sender: Button)
    {
        actionRequestHandler?(self, sender)
    }

    struct Model
    {
        var username: String = ""
        var email: String = ""
        var password: String = ""
        var confirmPassword: String = ""
    }
}

extension UpgradeAccountVC: LoadStatable
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

    func updateLoadState(_ animated: Bool = false)
    {
        switch loadState
        {
            case .normal, .error: do
            {
                activityVC?.hide(animated: true)
                activityVC = nil
            }

            case .loading: do
            {
                guard activityVC == nil else { return }
                activityVC = ActivityIndicatingViewController.presentEmbedded(in: self, embeddingMode: .over)
            }
        }
    }
}

extension UpgradeAccountVC: EmbeddableControllerContainerProtocol
{
    func getContaiterViewForEmbeddableViewController() -> UIView?
    {
        view
    }
}

extension UpgradeAccountVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        guard let text = textField.text, let textRange = Range(range, in: text) else { return true }

        let updatedText = text.replacingCharacters(in: textRange, with: string)

        switch textField.tag
        {
            case 1: model.username = updatedText
            case 2: model.email = updatedText
            case 3: model.password = updatedText
            case 4: model.confirmPassword = updatedText

            default: break
        }

        updateActionButton()
        updateTextFields()

        return false
    }
}
