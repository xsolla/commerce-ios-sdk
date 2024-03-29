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

class FloatingTitleTextField: BaseFloatingTitleTextField
{
    override func commonInit()
    {
        super.commonInit()
        applyDefaultStyle()
        updateAppearance(animated: false)
    }
}

class BaseFloatingTitleTextField: UIView
{
    // MARK: - Public

    var text: String? { textInput.text }

    var placeholder: String = "" { didSet { updateAppearance() } }
    var secureEntry: Bool = false { didSet { updateAppearance() } }
    weak var delegate: UITextFieldDelegate? { didSet { delegateProxy.delegate = delegate } }
    var secure: Bool = false { didSet { if oldValue != secure { updateSecureMode() } } }
    override var tag: Int { get { textInput.tag } set { textInput.tag = newValue } }
    var isEnabled = true { didSet { updateEnabledState() } }

    // MARK: - Setters

    func set(text: String?)
    {
        textInput.text = text
        if !text.isEmpty
        {
            titleState = .floating
            forceUpdateFloatingLabelPosition()
        }

        updateAppearance()
    }

    func set(errorText text: String?)
    {
        lastHintText = errorText ?? hintText
        errorText = text

        updateAppearance()
    }

    func set(hintText text: String?)
    {
        lastHintText = errorText ?? hintText
        hintText = text

        updateAppearance()
    }

    // Colors

    var titleStyle: Style = .default { didSet { updateAppearance() } }
    var textStyle: Style = .default { didSet { updateAppearance() } }
    var statusStyle: Style = .default { didSet { updateAppearance() } }

    var activeColor: UIColor = .black { didSet { updateAppearance() } }
    var normalColor: UIColor = .black { didSet { updateAppearance() } }
    var disabledColor: UIColor = .black { didSet { updateAppearance() } }

    var activeBackgroundColor: UIColor = .white { didSet { updateAppearance() } }
    var normalBackgroundColor: UIColor = .white { didSet { updateAppearance() } }
    var disabledBackgroundColor: UIColor = .white { didSet { updateAppearance() } }

    var statusColor: UIColor = .gray { didSet { updateAppearance() } }
    var errorColor: UIColor = .red { didSet { updateAppearance() } }

    var textColor: UIColor = .black { didSet { updateAppearance() } }
    var placeholderColor: UIColor = .black { didSet { updateAppearance() } }

    let horizontalPadding: CGFloat = 16

    // MARK: - Floating title state

    enum TitleState
    {
        case origin
        case floating
        case hidden
    }

    private var titleState = TitleState.origin

    // MARK: - Private

    private let delegateProxy = TextFieldDelegateProxy()
    fileprivate var textInput = SecureTextField(frame: .zero)
    private var errorText: String?
    private var lastHintText: String?
    private var hintText: String?
    private var canPerformLayout = false

    // MARK: - private UI

    private let containerView = UIView(frame: .zero)
    private let stackView = UIStackView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let statusLabel = UILabel(frame: .zero)
    private let statusLineView = UIView(frame: .zero)
    private let rightButton = UIButton(type: .custom)
    private var cnstrTitleLabelCenterY: NSLayoutConstraint?
    private var cnstrTitleLabelTop: NSLayoutConstraint?
    private var cnstrButtonTrailing: NSLayoutConstraint?
    private var cnstrTextFieldHeight: NSLayoutConstraint?
    private var cnstrStatusLineBottom: NSLayoutConstraint?

    private func setupStackView()
    {
        addSubview(stackView)
        stackView.pinToSuperview()
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    private func setupContainerView()
    {
        stackView.addArrangedSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderWidth = 0
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContainer)))
    }

    private func setupStatusLineView()
    {
        containerView.addSubview(statusLineView)

        statusLineView.translatesAutoresizingMaskIntoConstraints = false

        statusLineView.backgroundColor = .xsolla_inactiveWhite
    }

    private func setupStatusLabel()
    {
        stackView.addArrangedSubview(statusLabel)
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true
    }

    private func setupTextField()
    {
        textInput.delegate = delegateProxy

        containerView.addSubview(textInput)

        textInput.font = textStyle.font
        textInput.translatesAutoresizingMaskIntoConstraints = false

        textInput.editingStateChangeHandler =
        { [weak self] textField, editingState in

            self?.updateEditingState()
        }

        updateEditingState(animated: false)
        updateEnabledState()
    }

    private func setupRightButton()
    {
        containerView.addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.addTarget(self, action: #selector(onRevealButton), for: .touchUpInside)
    }

    private func setupConstraints()
    {
        cnstrTitleLabelTop = titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8)
        cnstrTitleLabelTop?.priority = .defaultHigh

        cnstrTitleLabelCenterY = titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        cnstrTitleLabelCenterY?.priority = .defaultHighest

        cnstrTextFieldHeight = textInput.heightAnchor.constraint(equalToConstant: 24)
        cnstrButtonTrailing = rightButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)

        cnstrStatusLineBottom = statusLineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                                       constant: 2)

        NSLayoutConstraint.activate(
        [
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Status line
            cnstrStatusLineBottom!,
            statusLineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            statusLineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            statusLineView.heightAnchor.constraint(equalToConstant: 1),

            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -horizontalPadding),
            cnstrTitleLabelTop!,
            cnstrTitleLabelCenterY!,

            // Text Field
            textInput.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            textInput.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -16),
            textInput.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            textInput.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            cnstrTextFieldHeight!,

            // Button
            rightButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            rightButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            rightButton.widthAnchor.constraint(equalToConstant: 44),
            cnstrButtonTrailing!
        ])
    }

    @objc
    private func onContainer()
    {
        _ = textInput.becomeFirstResponder()
    }

    var calculatedTitleColor: UIColor
    {
        errorText.isEmpty ? placeholderColor : errorColor
    }

    var calculatedHintColor: UIColor
    {
        errorText.nilIfEmpty == nil ? placeholderColor : errorColor
    }

    func updateAppearance(animated: Bool = true)
    {
        updateTitleLabel()
        updateStatusLabel(animated: animated)
        updateEditingState(animated: animated)

        statusLineView.backgroundColor = calculatedHintColor

        textInput.textColor = textColor
        textInput.isSecureTextEntry = secure

        if !isEnabled { containerView.backgroundColor = disabledBackgroundColor }
    }

    func updateStatusLabel(animated: Bool = true)
    {
        if let hint = errorText ?? hintText
        {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 16
            paragraphStyle.headIndent = 16
            paragraphStyle.tailIndent = 0

            let attibutedHint = hint.attributedMutable(statusStyle, color: calculatedHintColor)
            attibutedHint.addAttribute(.paragraphStyle,
                                       value: paragraphStyle,
                                       range: NSRange(location: 0,
                                                      length: attibutedHint.length))

            statusLabel.attributedText = attibutedHint

            if statusLabel.isHidden == false { return }
            statusLabel.isHidden = false
        }
        else
        {
            if statusLabel.isHidden == true { return }
            statusLabel.isHidden = true
        }

        guard animated else { self.superview?.layoutIfNeeded(); return }

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:
        {
            self.superview?.layoutIfNeeded()
        }, completion: nil )
    }

    // MARK: - Secure mode

    private func updateSecureMode()
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
    private func resetRightButton()
    {
        textInput.rightViewMode = .never
        rightButton.setImage(nil, for: .normal)
        rightButton.removeTarget(nil, action: nil, for: .allEvents)
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

    // MARK: - Enabled State

    private func updateEnabledState()
    {
        if isEnabled
        {
            isUserInteractionEnabled = true
            textInput.textColor = .xsolla_white
        }
        else
        {
            _ = textInput.resignFirstResponder()
            textInput.textColor = .xsolla_inactiveWhite
            isUserInteractionEnabled = false
        }

        updateEditingState(animated: false)
    }

    func updateTitleLabel()
    {
        titleLabel.attributedText = placeholder.attributed(titleStyle, color: calculatedTitleColor)
        textInput.tintColor = calculatedTitleColor
    }

    // MARK: - Floating title animations

    private func setupTitleLabel()
    {
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func updateEditingState(animated: Bool = true)
    {
        guard canPerformLayout else { return }

        if textInput.editingState == .normal
        {
            if textInput.text.isEmpty { transitionTitleLabelToOrigin(animated: true) }
            containerView.backgroundColor = normalBackgroundColor

            cnstrStatusLineBottom?.constant = (errorText.nilIfEmpty != nil) ? 0 : 1

            guard animated else { layoutIfNeeded(); return }

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:
            {
                self.layoutIfNeeded()
            }, completion: nil )

            return
        }

        if textInput.editingState == .editing
        {
            if textInput.text.isEmpty { transitionTitleLabelToFloating(animated: true) }
            containerView.backgroundColor = activeBackgroundColor

            cnstrStatusLineBottom?.constant = 0

            guard animated else { layoutIfNeeded(); return }

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:
            {
                self.layoutIfNeeded()
            }, completion: nil )

            return
        }
    }

    func transitionTitleLabelToOrigin(animated: Bool, forceUpdate: Bool = false)
    {
        guard canPerformLayout else { return }

        if titleState == .origin && !forceUpdate { return }
        titleState = .origin

        updateTitleLabel()

        cnstrTitleLabelCenterY?.priority = .defaultHighest

        guard animated else
        {
            self.titleLabel.transform = .identity
            self.layoutIfNeeded()
            return
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:
        {
            self.titleLabel.transform = .identity
            self.layoutIfNeeded()
        }, completion: nil )
    }

    func transitionTitleLabelToFloating(animated: Bool, forceUpdate: Bool = false)
    {
        guard canPerformLayout else { return }

        if titleState == .floating && !forceUpdate { return }
        titleState = .floating

        updateTitleLabel()

        let scaleFactor: CGFloat = 0.7

        cnstrTitleLabelCenterY?.priority = .defaultLow

        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        let translation = CGAffineTransform(translationX: -(self.titleLabel.bounds.width  * (1 - scaleFactor)) / 2,
                                            y: (-(self.titleLabel.bounds.height * (1 - scaleFactor)) / 2) + 3)

        guard animated else
        {
            self.titleLabel.transform = scale.concatenating(translation)
            self.layoutIfNeeded()
            return
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:
        {
            self.titleLabel.transform = scale.concatenating(translation)
            self.layoutIfNeeded()
        }, completion: nil )
    }

    func forceUpdateFloatingLabelPosition()
    {
        guard canPerformLayout else { return }

        if titleState == .floating { transitionTitleLabelToFloating(animated: false, forceUpdate: true) }
        else                       { transitionTitleLabelToOrigin(animated: false, forceUpdate: true) }
    }

    // MARK: - Overrides

    override func layoutIfNeeded()
    {
        if canPerformLayout { super.layoutIfNeeded() }
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()

        if !canPerformLayout
        {
            canPerformLayout = true
            layoutIfNeeded()
            forceUpdateFloatingLabelPosition()
            updateEditingState(animated: false)
        }

        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    // MARK: - First responder

    override func becomeFirstResponder() -> Bool
    {
        return textInput.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool
    {
        return textInput.resignFirstResponder()
    }

    override var canBecomeFirstResponder: Bool
    {
        return textInput.canBecomeFirstResponder
    }

    override var isFirstResponder: Bool
    {
        return textInput.isFirstResponder
    }

    // MARK: - Initialization

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit()
    {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false

        setupStackView()
        setupContainerView()
        setupStatusLineView()
        setupTitleLabel()
        setupStatusLabel()
        setupTextField()
        setupRightButton()

        setupConstraints()

        updateEditingState(animated: false)
    }
}

extension FloatingTitleTextField: StringUserInputValidatable
{
    var value: String? { text }
    func setError(text: String?) { set(errorText: text) }
}

extension FloatingTitleTextField
{
    func configureTextField(_ configure: ((UITextField) -> Void)) { configure(textInput) }

    @discardableResult
    func configureTextFieldDefaults() -> FloatingTitleTextField
    {
        configureTextField(defaultConfigure)

        return self
    }

    var defaultConfigure: (UITextField) -> Void
    {
        { textField in

            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.smartDashesType = .no
            textField.smartQuotesType = .no
            textField.spellCheckingType = .no
            textField.returnKeyType = .next
        }
    }
}

class SecureTextField: UITextField
{
    // MARK: - Editing state

    override var textContentType: UITextContentType!
    {
        set
        {
            if #available(iOS 12.0, *) { super.textContentType = .oneTimeCode }
            else                       { super.textContentType = newValue }
        }
        get { super.textContentType }
    }

    var editingStateChangeHandler: ((SecureTextField, EditingState) -> Void)?
    var editingState: EditingState = .normal { didSet { editingStateChangeHandler?(self, editingState) } }

    enum EditingState
    {
        case normal
        case editing
    }

    override var isSecureTextEntry: Bool
    {
        didSet { if isFirstResponder { _ = becomeFirstResponder() } }
    }

    override func becomeFirstResponder() -> Bool
    {
        let success = super.becomeFirstResponder()

        if success { editingState = .editing }

        if isSecureTextEntry, let text = self.text
        {
            self.text?.removeAll()
            insertText(text)
        }

        return success
    }

    override func resignFirstResponder() -> Bool
    {
        let success = super.resignFirstResponder()

        if success { editingState = .normal }

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

extension FloatingTitleTextField
{
    enum DefaultColors
    {
        static let activeColor: UIColor = .xsolla_onSurfaceMedium
        static let normalColor: UIColor = .xsolla_onSurfaceDisabled
        static let disabledColor: UIColor = .xsolla_onSurfaceDisabled

        static let statusColor: UIColor = .gray
        static let errorColor: UIColor = .red

        static let activeBackgroundColor: UIColor = .xsolla_inputFieldNormal
        static let normalBackgroundColor: UIColor = .xsolla_inputFieldNormal
        static let disabledBackgroundColor: UIColor = .xsolla_inputFieldDisabled

        static let textColor: UIColor = .xsolla_white
        static let placeholderColor: UIColor = .xsolla_onSurfaceMedium
    }

    enum DefaultStyles
    {
        static let titleStyle: Style = .description
        static let textStyle: Style = .description
        static let statusStyle: Style = .notification
    }

    func applyDefaultStyle()
    {
        activeColor = DefaultColors.activeColor
        normalColor = DefaultColors.normalColor
        disabledColor = DefaultColors.disabledColor

        statusColor = DefaultColors.statusColor
        errorColor = DefaultColors.errorColor

        activeBackgroundColor = DefaultColors.activeBackgroundColor
        normalBackgroundColor = DefaultColors.normalBackgroundColor
        disabledBackgroundColor = DefaultColors.disabledBackgroundColor

        textColor = DefaultColors.textColor
        placeholderColor = DefaultColors.placeholderColor

        titleStyle = DefaultStyles.titleStyle
        textStyle = DefaultStyles.textStyle
        statusStyle = DefaultStyles.statusStyle
    }
}
