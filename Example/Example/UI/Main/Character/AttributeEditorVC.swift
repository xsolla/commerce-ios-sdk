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

protocol AttributeEditorVCProtocol: BaseViewController
{
    var userAttribute: UnifiedUserAttribute? { get }
    var dismissRequestHandler: ((AttributeEditorVCProtocol) -> Void)? { get set }
    var saveAttributeRequestHandler: ((AttributeEditorVCProtocol) -> Void)? { get set }
    var removeAttributeRequestHandler: ((AttributeEditorVCProtocol) -> Void)? { get set }
}

class AttributeEditorVC: BaseViewController, AttributeEditorVCProtocol
{
    var dismissRequestHandler: ((AttributeEditorVCProtocol) -> Void)?
    var saveAttributeRequestHandler: ((AttributeEditorVCProtocol) -> Void)?
    var removeAttributeRequestHandler: ((AttributeEditorVCProtocol) -> Void)?

    var initialUserAttribute: UnifiedUserAttribute?
    var userAttribute: UnifiedUserAttribute?

    private var attributeKey: String?
    private var attributeValue: String?

    // Outlets
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var attributeKeyTextField: FloatingTitleTextField!
    @IBOutlet private weak var attributeValueTextField: FloatingTitleTextField!

    @IBOutlet private weak var discardChangesButton: Button!
    @IBOutlet private weak var saveChangesButton: Button!
    @IBOutlet private weak var deleteAttributeButton: Button!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        let titleText = "Custom attribute"
        titleLabel.attributedText = titleText.attributed(.heading1, color: .xsolla_white)

        setupButtons()
        setupTextFields()

        resetToInitialValues()
    }

    private func resetToInitialValues()
    {
        userAttribute = nil
        attributeKey = initialUserAttribute?.key
        attributeValue = initialUserAttribute?.value

        updateTextFields()
        updateSaveButton()
        updateDiscardButton()
    }

    private func setupButtons()
    {
        discardChangesButton.setupAppearance(config: Button.smallOutlined)
        discardChangesButton.setTitle(L10n.AttributeEditor.Button.discard, for: .normal)

        saveChangesButton.setupAppearance(config: Button.smallContained)
        let saveChangesTitle = (initialUserAttribute == nil)
                             ? L10n.AttributeEditor.Button.add
                             : L10n.AttributeEditor.Button.save

        saveChangesButton.setTitle(saveChangesTitle, for: .normal)

        deleteAttributeButton.setupAppearance(config: Button.smallOutlinedDestructive)
        deleteAttributeButton.setTitle(L10n.AttributeEditor.Button.delete, for: .normal)

        if initialUserAttribute == nil
        {
            deleteAttributeButton.isHidden = true
        }
    }

    private func setupTextFields()
    {
        attributeKeyTextField.placeholder = L10n.AttributeEditor.TextField.Placeholder.key
        attributeKeyTextField.delegate = self
        attributeKeyTextField.tag = 0

        attributeValueTextField.placeholder = L10n.AttributeEditor.TextField.Placeholder.value
        attributeValueTextField.delegate = self
        attributeValueTextField.tag = 1

        if initialUserAttribute != nil
        {
            attributeKeyTextField.isUserInteractionEnabled = false
            attributeKeyTextField.normalBackgroundColor = .xsolla_inputFieldDisabled
        }
    }

    private func updateTextFields()
    {
        attributeKeyTextField.set(text: initialUserAttribute?.key)
        attributeValueTextField.set(text: initialUserAttribute?.value)
    }

    private func updateDiscardButton()
    {
        var hidden = true

        if attributeKey != initialUserAttribute?.key { hidden = false }
        if attributeValue != initialUserAttribute?.value { hidden = false }

        discardChangesButton.setEnabled(!hidden, animated: true)
    }

    private func updateSaveButton()
    {
        var enabled = true

        if attributeKey.nilIfEmpty == nil { enabled = false }
        if attributeValue.nilIfEmpty == nil { enabled = false }

        if attributeKey == initialUserAttribute?.key,
           attributeValue == initialUserAttribute?.value

        {
            enabled = false
        }

        saveChangesButton.setEnabled(enabled, animated: true)
    }

    @IBAction private func onDismissButton(_ sender: UIButton)
    {
        dismissRequestHandler?(self)
    }

    @IBAction private func onDiscardButton(_ sender: UIButton)
    {
        resetToInitialValues()
    }

    @IBAction private func onSaveButton(_ sender: UIButton)
    {
        guard let key = attributeKey, let value = attributeValue else { return }

        // Updating a custom attribute
        if let initialUserAttribute = initialUserAttribute
        {
            let attribute = UnifiedUserAttribute(key: initialUserAttribute.key,
                                                 value: value,
                                                 permission: initialUserAttribute.permission,
                                                 readonly: false)
            userAttribute = attribute
        }
        // Addind a new custom attribute
        else
        {
            let attribute = UnifiedUserAttribute(key: key,
                                                 value: value,
                                                 permission: nil,
                                                 readonly: false)
            userAttribute = attribute
        }

        saveAttributeRequestHandler?(self)
    }

    @IBAction private func onDeleteButton(_ sender: UIButton)
    {
        userAttribute = initialUserAttribute
        removeAttributeRequestHandler?(self)
    }
}

extension AttributeEditorVC: UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        updateDiscardButton()
        updateSaveButton()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        guard let text = textField.text, let textRange = Range(range, in: text) else { return true }

        let updatedText = text.replacingCharacters(in: textRange, with: string)

        if textField.tag == 0 { attributeKey = updatedText }
        else                  { attributeValue = updatedText }

        updateDiscardButton()
        updateSaveButton()

        return true
    }
}
