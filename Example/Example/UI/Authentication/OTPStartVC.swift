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
import XsollaSDKStoreKit

protocol OTPStartVCProtocol: BaseViewController, LoadStatable
{
    var actionButtonHandler: ((OTPStartVCProtocol, UIView) -> Void)? { get set }
    var codeRequestData: String? { get }
}

class OTPStartVC: BaseViewController, OTPStartVCProtocol
{
    var actionButtonHandler: ((OTPStartVCProtocol, UIView) -> Void)?
    var codeRequestData: String? { inputTextField.text }
    
    var configuration: OTPSequenceConfiguration!
    var localization: OTPSequenceConfiguration.Localization { configuration.l10n }

    var loadState: LoadState = .normal
    var activityIndicator: ActivityIndicator?

    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var inputTextField: FloatingTitleTextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        title = localization.startTitle

        inputTextField.placeholder = localization.startPlaceholder
        inputTextField.delegate = self

        if let configure = configuration.configurePayloadTextField { inputTextField.configureTextField(configure) }

        updateActionButton()
    }

    func updateActionButton()
    {
        actionButton.setupAppearance(config: Button.largeContained)

        actionButton.setTitle(nil, for: .normal)
        actionButton.setTitle(localization.startActionButton,
                              attributes: Style.button.attributes(withColor: .xsolla_white))

        actionButton.isEnabled = (inputTextField.text ?? "").notEmpty
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }

    @IBAction private func onActionButton(_ sender: Button)
    {
        actionButtonHandler?(self, sender)
    }
}

extension OTPStartVC: LoadStatable
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
                hideActivityIndicator()

                updateActionButton()
                inputTextField.setActive(true)
            }

            case .loading(let view): do
            {
                actionButton.isEnabled = false
                inputTextField.setActive(false)

                if view === actionButton
                {
                    actionButton.setTitle(nil, attributes: Style.button.attributes(withColor: .xsolla_white))
                    actionButton.setTitle(nil, for: .normal)
                    showActivityIndicator(for: actionButton)
                }
            }
        }
    }

    func showActivityIndicator(for view: UIView)
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

extension OTPStartVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        guard let text = textField.text, let textRange = Range(range, in: text) else { return true }

        let updatedText = text.replacingCharacters(in: textRange, with: string)

        if updatedText.isEmpty { actionButton.isEnabled = false } else { actionButton.isEnabled = true }

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        textField.text = nil

        return true
    }
}

fileprivate extension FloatingTitleTextField
{
    func setActive(_ isActive: Bool)
    {
        isUserInteractionEnabled = isActive
        normalBackgroundColor = isActive ? .xsolla_inputFieldNormal : .xsolla_inputFieldDisabled
    }
}
