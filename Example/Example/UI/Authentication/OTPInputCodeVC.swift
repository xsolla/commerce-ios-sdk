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

protocol OTPInputCodeVCProtocol: BaseViewController, LoadStatable
{
    var actionButtonHandler: ((OTPInputCodeVCProtocol, UIView) -> Void)? { get set }
    var resendCodeButtonHandler: ((OTPInputCodeVCProtocol) -> Void)? { get set }
    var code: String? { get }
    var codeExpirationInterval: (() -> TimeInterval) { get set }
    func startTimer()
}

class OTPInputCodeVC: BaseViewController, OTPInputCodeVCProtocol
{
    @IBOutlet private weak var inputTextField: FloatingTitleTextField!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var resendCodeButton: UIButton!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var restrictionsLabel: UILabel!

    var actionButtonHandler: ((OTPInputCodeVCProtocol, UIView) -> Void)?
    var resendCodeButtonHandler: ((OTPInputCodeVCProtocol) -> Void)?
    var code: String? { inputTextField.text }
    var codeExpirationInterval: (() -> TimeInterval) = { 0 }

    var loadState: LoadState = .normal
    var activityIndicator: ActivityIndicator?

    var configuration: OTPSequenceConfiguration!
    var localization: OTPSequenceConfiguration.Localization { configuration.l10n }

    var timer: Timer?

    func startTimer()
    {
        stopTimer()

        UIView.performWithoutAnimation { resendCodeButton.isEnabled = true; resendCodeButton.layoutIfNeeded() }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block:
        { [weak self] _ in

            self?.timerTick()
        })

        timerTick()
    }

    func stopTimer()
    {
        timer?.invalidate()
        timer = nil
    }

    func timerTick()
    {
        updateActionButton()
        updateInfoLabel()

        if codeExpirationInterval() < 1 { stopTimer() }
    }

    let formatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "mm:ss"

        return formatter
    }()

    func updateInfoLabel()
    {
        let interval = codeExpirationInterval()

        guard interval >= 1 else
        {
            infoLabel.attributedText = localization.codeCodeExpired.attributed(timerTimeStyleAttributes)
            return
        }

        let intervalString = formatter.string(from: Date(timeIntervalSinceReferenceDate: interval))
        let attributedIntervalString = intervalString.attributed(timerTimeStyleAttributes)

        let attributedString = localization.codeCodeExpireIn.attributedMutable(timerTextStyleAttributes)
        attributedString.append(attributedIntervalString)

        infoLabel.attributedText = attributedString
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        title = localization.codeTitle
        setupRestrictionsLabel()

        inputTextField.placeholder = localization.codePlaceholder
        inputTextField.delegate = self
        
        if let configure = configuration.configureCodeTextField { inputTextField.configureTextField(configure) }

        infoLabel.attributedText = " ".attributed(timerTextStyleAttributes)

        actionButtonTitle = localization.codeActionButton

        setupResendCodeButton()

        updateActionButton()
    }

    func setupResendCodeButton()
    {
        let title = localization.codeResendCode
        resendCodeButton.setAttributedTitle(title.attributed(resendButtonStyleAttributes), for: .normal)
        resendCodeButton.setAttributedTitle(title.attributed(resendButtonDisabledStyleAttributes), for: .disabled)
    }

    func setupRestrictionsLabel()
    {
        let paragraphStyle = NSMutableParagraphStyle()
        let indent: CGFloat = 20

        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.headIndent = indent
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: indent, options: [:])]
        paragraphStyle.paragraphSpacing = 16

        let attrs: [NSAttributedString.Key: Any] =
        [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: Style.discount.font,
            NSAttributedString.Key.foregroundColor: UIColor.xsolla_inactiveWhite
        ]

        let messageText = NSMutableAttributedString(string: L10n.Auth.Otp.codeRestrictionsInformation,
                                                    attributes: attrs)
        restrictionsLabel.numberOfLines = 0
        restrictionsLabel.attributedText = messageText
    }

    var actionButtonTitle: String?

    func updateActionButton()
    {
        actionButton.setupAppearance(config: Button.largeContained)

        actionButton.setTitle(actionButtonTitle, for: .normal)
        actionButton.setTitle(actionButtonTitle,
                              attributes: Style.button.attributes(withColor: .xsolla_white))

        if case .loading = loadState {} else
        {
            actionButton.isEnabled = (inputTextField.text ?? "").notEmpty
        }

        if codeExpirationInterval() < 1 { actionButton.isEnabled = false }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        updateActionButton()
        updateInfoLabel()
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        stopTimer()
        _ = inputTextField.resignFirstResponder()
    }

    @IBAction private func onActionButton(_ sender: Button)
    {
        actionButtonHandler?(self, sender)
    }

    @IBAction private func onResendCodeButton(_ sender: UIButton)
    {
        UIView.performWithoutAnimation { resendCodeButton.isEnabled = false; resendCodeButton.layoutIfNeeded() }
        resendCodeButtonHandler?(self)
    }

    // MARK: - Internal

    var timerTextStyleAttributes = Style.notification.attributes(withColor: .xsolla_onSurfaceMedium)
    var timerTimeStyleAttributes = Style.notification.attributes(withColor: .xsolla_magenta)
    var resendButtonStyleAttributes = Style.link.attributes(withColor: .xsolla_inactiveWhite)
    var resendButtonDisabledStyleAttributes = Style.link.attributes(withColor: .xsolla_inactiveWhite50)
}

extension OTPInputCodeVC: LoadStatable
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
                actionButtonTitle = localization.codeActionButton

                updateActionButton()
                inputTextField.setActive(true)
            }

            case .loading: do
            {
                actionButtonTitle = nil
                updateActionButton()
                showActivityIndicator(for: actionButton)

                actionButton.isEnabled = false
                inputTextField.setActive(false)
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

extension OTPInputCodeVC: UITextFieldDelegate
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
