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

protocol AuthenticationOptionsVCProtocol: BaseViewController, LoadStatable
{
    var loginRequestHandler: ((AuthenticationOption) -> Void)? { get set }
}

class AuthenticationOptionsSelectorVC: BaseViewController, AuthenticationOptionsVCProtocol
{
    var loginRequestHandler: ((AuthenticationOption) -> Void)?

    // LoadStatable
    private var loadState: LoadState = .normal
    private var activityVC: ActivityIndicatingViewController?

    override var navigationBarIsHidden: Bool? { false }

    @IBOutlet private weak var optionsCommonInfoLabel: UILabel!
    @IBOutlet private weak var passwordLoginExplanationLabel: UILabel!

    @IBOutlet private weak var demoUserButton: Button!
    @IBOutlet private weak var guestUserButton: Button!
    @IBOutlet private weak var emailLoginButton: Button!
    @IBOutlet private weak var phoneLoginButton: Button!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        title = L10n.Auth.Button.authenticationOptions

        demoUserButton.setupAppearance(config: Button.largeOutlined)
        guestUserButton.setupAppearance(config: Button.largeOutlined)
        emailLoginButton.setupAppearance(config: Button.largeOutlined)
        phoneLoginButton.setupAppearance(config: Button.largeOutlined)

        optionsCommonInfoLabel.attributedText =
            L10n.Auth.LoginOptions.Text.intro.attributed(.description, color: .xsolla_inactiveWhite)
        passwordLoginExplanationLabel.attributedText =
            L10n.Auth.LoginOptions.Text.passwordLoginExplanation.attributed(.discount, color: .xsolla_inactiveWhite)

        let attributes = Style.button.attributes(withColor: .xsolla_inactiveWhite)

        demoUserButton.setTitle(L10n.Auth.LoginOptions.Button.logInAsDemoUser, attributes: attributes)
        guestUserButton.setTitle(L10n.Auth.LoginOptions.Button.logInWithDeviceId, attributes: attributes)
        emailLoginButton.setTitle(L10n.Auth.LoginOptions.Button.passwordlessAuthorization, attributes: attributes)
        phoneLoginButton.setTitle(L10n.Auth.LoginOptions.Button.logInWithPhone, attributes: attributes)
    }

    @IBAction private func onDemoUserButton(_ sender: Button) { loginRequestHandler?(.demoUser) }
    @IBAction private func onEmailButton(_ sender: Button) { loginRequestHandler?(.email) }
    @IBAction private func onPhoneButton(_ sender: Button) { loginRequestHandler?(.phone) }
    @IBAction private func onGuestUserButton(_ sender: Button) { loginRequestHandler?(.deviceId) }
}

extension AuthenticationOptionsSelectorVC: LoadStatable
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

extension AuthenticationOptionsSelectorVC: EmbeddableControllerContainerProtocol
{
    func getContaiterViewForEmbeddableViewController() -> UIView?
    {
        view
    }
}
