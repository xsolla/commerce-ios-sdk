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

protocol AppDeveloperSettingsVCProtocol: BaseViewController
{
    var actionButtonHandler: ((AppDeveloperSettingsVCProtocol) -> Void)? { get set }
    var resetButtonHandler: (() -> Void)? { get set }

    var model: AppDeveloperSettingsVC.Model { get }
    func setup(with model: AppDeveloperSettingsVC.Model)
}

class AppDeveloperSettingsVC: BaseViewController, AppDeveloperSettingsVCProtocol
{
    override var navigationBarIsHidden: Bool? { false }

    var actionButtonHandler: ((AppDeveloperSettingsVCProtocol) -> Void)?
    var resetButtonHandler: (() -> Void)?

    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var resetButton: Button!
    @IBOutlet private weak var oAuthClientIdTextField: FloatingTitleTextField!
    @IBOutlet private weak var loginIdTextField: FloatingTitleTextField!
    @IBOutlet private weak var projectIdTextField: FloatingTitleTextField!
    @IBOutlet private weak var webshopUrlTextField: FloatingTitleTextField!

    var model: Model = Model(oAuthClientId: "", loginId: "", projectId: "", webshopUrl: "")

    func setup(with model: Model)
    {
        self.model = model
        updateTextFields()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        title = L10n.AppDeveloperSettings.title

        actionButton.setupAppearance(config: Button.largeContained)
        actionButton.setTitle(L10n.AppDeveloperSettings.ActionButton.title,
                              attributes: Style.button.attributes(withColor: .xsolla_white))
        resetButton.setupAppearance(config: Button.largeOutlined)
        resetButton.setTitle(L10n.AppDeveloperSettings.ResetButton.title,
                             attributes: Style.button.attributes(withColor: .xsolla_inactiveWhite))

        oAuthClientIdTextField.tag = TextFieldTag.oAuthClientId.rawValue
        loginIdTextField.tag = TextFieldTag.loginId.rawValue
        projectIdTextField.tag = TextFieldTag.projectId.rawValue
        webshopUrlTextField.tag = TextFieldTag.webshopUrl.rawValue

        oAuthClientIdTextField.placeholder = L10n.AppDeveloperSettings.OauthClientId.placeholder
        loginIdTextField.placeholder = L10n.AppDeveloperSettings.LoginId.placeholder
        projectIdTextField.placeholder = L10n.AppDeveloperSettings.ProjectId.placeholder
        webshopUrlTextField.placeholder = L10n.AppDeveloperSettings.WebshopUrl.placeholder

        oAuthClientIdTextField.delegate = self
        loginIdTextField.delegate = self
        projectIdTextField.delegate = self
        webshopUrlTextField.delegate = self

        updateTextFields()
    }

    func updateTextFields()
    {
        guard isViewLoaded else { return }

        oAuthClientIdTextField.set(text: model.oAuthClientId)
        loginIdTextField.set(text: model.loginId)
        projectIdTextField.set(text: model.projectId)
        webshopUrlTextField.set(text: model.webshopUrl)
    }

    @IBAction private func onActionButton(_ sender: Button)
    {
        actionButtonHandler?(self)
    }

    @IBAction private func onResetButton(_ sender: Button)
    {
        resetButtonHandler?()
    }
}

extension AppDeveloperSettingsVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        guard let text = textField.text, let textRange = Range(range, in: text) else { return true }

        let updatedText = text.replacingCharacters(in: textRange, with: string)
        textField.text = updatedText

        switch TextFieldTag(rawValue: textField.tag)
        {
            case .oAuthClientId: model.oAuthClientId = updatedText
            case .loginId: model.loginId = updatedText
            case .projectId: model.projectId = updatedText
            case .webshopUrl: model.webshopUrl = updatedText
            default: break
        }

        return false
    }
}

extension AppDeveloperSettingsVC
{
    struct Model
    {
        var oAuthClientId: String
        var loginId: String
        var projectId: String
        var webshopUrl: String
    }

    enum TextFieldTag: Int
    {
        case oAuthClientId = 1
        case loginId = 2
        case projectId = 3
        case webshopUrl = 4
    }
}
