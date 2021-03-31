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

import MaterialComponents.MaterialTextFields

//@IBDesignable
class FloatingTitleTextField: UIView
{
    var text: String? { textInput.text }
    
    override var tag: Int { get { textInput.tag } set { textInput.tag = newValue } }

    weak var delegate: UITextFieldDelegate? { didSet { delegateProxy.delegate = delegate } }
    private let delegateProxy = DelegateProxy()
    
    var secure: Bool = false { didSet { if oldValue != secure { setupSecureMode() } } }
    
    // Colors
    
    var activeColor: UIColor? = .xsolla_onSurfaceMedium { didSet { updateAppearance() } }
    var normalColor: UIColor? = .xsolla_onSurfaceDisabled { didSet { updateAppearance() } }
    
    var activeBackgroundColor: UIColor? = .xsolla_inputFieldNormal { didSet { updateAppearance() } }
    var normalBackgroundColor: UIColor? = .xsolla_inputFieldNormal { didSet { updateAppearance() } }
    
    var textColor: UIColor? = .xsolla_white { didSet { updateAppearance() } }
    var placeholderColor: UIColor? = .xsolla_onSurfaceMedium { didSet { updateAppearance() } }
    
    // Other
    
    var placeholder: String = "" { didSet { updateAppearance() } }
    var secureEntry: Bool = false { didSet { updateAppearance() } }
    
    // MARK: - Setters
    
    func set(text: String?)
    {
        textInput.text = text

        updateAppearance()
    }
    
    func set(errorText text: String?)
    {
        errorText = text

        updateAppearance()
    }
    
    func set(hintText text: String?)
    {
        hintText = text

        updateAppearance()
    }
    
    // MARK: - Private fields
    
    private let rightButton: UIButton = UIButton(frame: .zero)
    private var textInput = TextField()
    private var controller: TextInputControllerFilled!
    private var errorText: String?
    private var hintText: String?
    
    // MARK: - Setup
    
    private func setupInputView()
    {
        textInput.translatesAutoresizingMaskIntoConstraints = false
        textInput.clearButtonMode = .never
        textInput.rightView = rightButton
        textInput.rightViewMode = .never
        self.addSubview(textInput)
        
        NSLayoutConstraint.activate(
        [
            textInput.topAnchor.constraint(equalTo: self.topAnchor),
            textInput.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textInput.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textInput.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        setupSecureMode()
        updateInputView()
        
        textInput.delegate = delegateProxy
    }
    
    private func setupContoller()
    {
        controller = TextInputControllerFilled(textInput: textInput)
        controller.textInput?.leadingUnderlineLabel.numberOfLines = 0
        updateController()
        
        controller.inlinePlaceholderFont = .xolla_description
        controller.textInputFont = .xolla_description
        controller.leadingUnderlineLabelFont = .xolla_notification
        controller.trailingUnderlineLabelFont = .xolla_notification
        controller.leadingUnderlineLabelTextColor = .xsolla_onSurfaceMedium
        controller.errorColor = .xsolla_magenta
        controller.borderRadius = Shape.largeCornerRadius
    }
    
    // MARK: - Update
    
    private func updateInputView()
    {
        textInput.textColor = textColor
        textInput.isSecureTextEntry = secure
    }
    
    private func updateController()
    {
        guard controller != nil else { return }

        controller.placeholderText = placeholder
        
        controller.activeColor = activeColor
        controller.normalColor = .clear
        controller.borderFillColor = normalBackgroundColor
        controller.floatingPlaceholderActiveColor = normalColor
        controller.floatingPlaceholderNormalColor = normalColor
        controller.inlinePlaceholderColor = placeholderColor

        controller.setHelperText(hintText, helperAccessibilityLabel: nil)
        controller.setErrorText(errorText, errorAccessibilityValue: nil)
    }
        
    private func updateAppearance()
    {
        updateInputView()
        updateController()
    }
    
    private func resetRightButton()
    {
        textInput.rightViewMode = .never
        rightButton.setImage(nil, for: .normal)
        rightButton.removeTarget(nil, action: nil, for: .allEvents)
    }

    private func setupSecureMode()
    {        
        textInput.isSecureTextEntry = secure
        
        if secure
        {
            rightButton.addTarget(self, action: #selector(onRevealButton), for: .touchUpInside)
            updateSecureButton()
            textInput.rightViewMode = .always
        }
        else
        {
            resetRightButton()
        }
    }
    
    @objc
    private func onRevealButton()
    {
        textInput.isSecureTextEntry.toggle()
        
        updateSecureButton()
    }
    
    private func updateSecureButton()
    {
        let image = textInput.isSecureTextEntry ? Asset.Images.textfieldIsSecure.image
                                                : Asset.Images.textfieldNotSecure.image
        
        rightButton.setImage(image, for: .normal)
    }
    
    // MARK: - Lifecicle
    
    override func layoutSubviews()
    {
        if controller == nil
        {
            setupInputView()
            setupContoller()
        }
    }
}

class TextInputControllerFilled: MDCTextInputControllerFilled
{
    override func textInsets(_ defaultInsets: UIEdgeInsets,
                             withSizeThatFitsWidthHint widthHint: CGFloat) -> UIEdgeInsets
    {
        var insets = super.textInsets(defaultInsets, withSizeThatFitsWidthHint: widthHint)

        let offset = (errorText.nilIfEmpty == nil && helperText.nilIfEmpty == nil) ? 26 : 6

        insets.bottom -= CGFloat(offset)
        insets.right += 8
        return insets
    }
}

private class TextField: MDCTextField
{
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect
    {
        var newBounds = super.rightViewRect(forBounds: bounds)
        newBounds.origin.x -= 8
        
        return newBounds
    }
    
    override var isSecureTextEntry: Bool
    {
        didSet { if isFirstResponder { _ = becomeFirstResponder() } }
    }

    override func becomeFirstResponder() -> Bool
    {
        let success = super.becomeFirstResponder()

        if isSecureTextEntry, let text = self.text
        {
            self.text?.removeAll()
            insertText(text)
        }

        return success
    }

    func setPasswordVisibility(on: Bool)
    {
        isSecureTextEntry = !on

        if let existingText = text, isSecureTextEntry
        {
            /* When toggling to secure text, all text will be purged if the user
             continues typing unless we intervene. This is prevented by first
             deleting the existing text and then recovering the original text. */
            deleteBackward()

            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument)
            {
                replace(textRange, withText: existingText)
            }
        }

        /* Reset the selected text range since the cursor can end up in the wrong
         position after a toggle because the text might vary in width */
        if let existingSelectedTextRange = selectedTextRange
        {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
}

extension FloatingTitleTextField: StringUserInputValidatable
{
    var value: String? { text }
    func setError(text: String?) { set(errorText: text) }
}

extension FloatingTitleTextField
{
    private class DelegateProxy: TextFieldDelegateProxy {}
}
