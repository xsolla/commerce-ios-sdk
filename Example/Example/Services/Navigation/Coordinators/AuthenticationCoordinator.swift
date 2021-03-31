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

protocol AuthenticationCoordinatorProtocol: Coordinator, Finishable { }

class AuthenticationCoordinator: BaseCoordinator<AuthenticationCoordinator.Dependencies,
                                                 AuthenticationCoordinator.Params>,
                                 AuthenticationCoordinatorProtocol
{
    var webRedirectHandler: WebRedirectHandler?

    override func start()
    {
        let viewController = dependencies.viewControllerFactory.createAuthenticationMainVC(params: .none)

        viewController.loginRequestHandler =
        { [weak self] viewController, sender, formData in
            logger.info(.ui, domain: .example) { "Auth coordinator - loginRequestHandler \(formData)" }
            self?.loginRequestHandler(formData: formData, forVC: viewController, sender: sender)
        }

        viewController.demoUserLoginRequestHandler =
        { [weak self] viewController, sender in
            logger.info(.ui, domain: .example) { "Auth coordinator - demoUserLoginRequestHandler" }
            self?.demoUserLoginRequestHandler(forVC: viewController, sender: sender)
        }

        viewController.signupRequestHandler =
        { [weak self] viewController, sender, formData in
            logger.info(.ui, domain: .example) { "Auth coordinator - signupRequestHandler \(formData)" }
            self?.signupRequestHandler(formData: formData, forVC: viewController, sender: sender)
        }

        viewController.privacyPolicyRequestHandler =
        { [weak self] in
            logger.info(.ui, domain: .example) { "Auth coordinator - privacyPolicyRequestHandler" }
            self?.privacyPolicyRequestHandler()
        }

        viewController.socialNetworkLoginRequestHandler =
        { [weak self] vc, network in
            logger.info(.ui, domain: .example) { "Auth coordinator - socialNetworkLoginRequestHandler \(network)" }
            self?.socialNetworkLoginRequestHandler(network: network, forVC: vc)
        }

        viewController.moreSocialNetworksRequestHandler =
        { [weak self] vc in
            logger.info(.ui, domain: .example) { "Auth coordinator - moreSocialNetworksRequestHandler" }
            self?.moreSocialNetworksRequestHandler(forVC: vc)
        }

        viewController.passwordRecoveryRequestHandler =
        { [weak self] in
            logger.info(.ui, domain: .example) { "Auth coordinator - passwordRecoveryRequestHandler" }
            self?.passwordRecoveryRequestHandler()
        }

        pushViewController(viewController)
    }

    func loginRequestHandler(formData: LoginFormData, forVC viewController: LoginVCProtocol, sender: UIView)
    {
        viewController.setState(.loading(sender), animated: true)

        dependencies.xsollaSDK.authByUsernameAndPasswordJWT(username: formData.username,
                                                            password: formData.password,
                                                            clientId: AppConfig.loginClientId,
                                                            scope: "offline")
        { [weak self, weak viewController] result in guard let self = self else { return }
            switch result
            {
                case .success: do
                {
                    viewController?.setState(.normal, animated: true)
                    self.onFinish?(self)
                }

                case .failure(let error): do
                {
                    viewController?.setState(.error(nil), animated: true)
                    logger.error { error }
                }
            }
        }
    }

    func demoUserLoginRequestHandler(forVC viewController: LoginVCProtocol, sender: UIView)
    {
        viewController.setState(.loading(sender), animated: true)

        dependencies.xsollaSDK.authByUsernameAndPasswordJWT(username: AppConfig.demoUsername,
                                                            password: AppConfig.demoPassword,
                                                            clientId: AppConfig.loginClientId,
                                                            scope: "offline")
        { [weak self, weak viewController] result in guard let self = self else { return }
            switch result
            {
                case .success: do
                {
                    viewController?.setState(.normal, animated: true)
                    self.onFinish?(self)
                }

                case .failure(let error): do
                {
                    viewController?.setState(.error(nil), animated: true)
                    logger.error { error }
                }
            }
        }
    }

    func signupRequestHandler(formData: SignupFormData, forVC viewController: SignupVCProtocol, sender: UIView)
    {
        viewController.setState(.loading(sender), animated: true)

        dependencies.xsollaSDK.registerNewUser(oAuth2Params: .init(clientId: AppConfig.loginClientId,
                                                                   state: UUID().uuidString,
                                                                   scope: "offline",
                                                                   redirectUri: AppConfig.redirectURL),
                                               username: formData.username,
                                               password: formData.password,
                                               email: formData.email,
                                               acceptConsent: nil,
                                               fields: nil,
                                               promoEmailAgreement: nil)
        { [weak self, weak viewController] result in guard let self = self else { return }
            switch result
            {
                case .success(let url): do
                {
                    viewController?.setState(.normal, animated: true)

                    guard let url = url,
                          let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let authCode = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value
                    else
                    {
                        logger.info { "Registration info was sent to your email." }
                        self.showRegistrationSuccessAlert()
                        return
                    }

                    self.handleAuthCode(authCode)
                }

                case .failure(let error): do
                {
                    viewController?.setState(.error(nil), animated: true)
                    logger.error { error }
                }
            }
        }
    }

    func privacyPolicyRequestHandler()
    {

    }

    func socialNetworkLoginRequestHandler(network: SocialNetwork, forVC viewController: LoginVCProtocol)
    {
        viewController.setState(.loading(nil), animated: true)
        dependencies.xsollaSDK.getLinkForSocialAuth(providerName: network.rawValue,
                                                    oauth2params: .init(clientId: AppConfig.loginClientId,
                                                                        state: UUID().uuidString,
                                                                        scope: "offline",
                                                                        redirectUri: AppConfig.redirectURL))
        { [weak self, weak viewController] result in
            switch result
            {
                case .success(let url): do
                {
                    viewController?.setState(.normal, animated: true)
                    self?.startSocialAuthSession(url: url)
                }

                case .failure(let error): do
                {
                    viewController?.setState(.error(nil), animated: true)
                    logger.error { error }
                }
            }
        }
    }

    func moreSocialNetworksRequestHandler(forVC viewController: LoginVCProtocol)
    {
        let params: [SocialNetwork] = [.linkedin, .twitter]
        let socialNetworksVC = dependencies.viewControllerFactory.createSocialNetworksListVC(params: params)

        socialNetworksVC.onSocialNetwork =
        { [weak self, weak socialNetworksVC] network in

            logger.info(.ui, domain: .example) { "Auth coordinator - socialNetworkLoginRequestHandler \(network)" }
            socialNetworksVC?.dismiss(animated: true)
            {
                self?.socialNetworkLoginRequestHandler(network: network, forVC: viewController)
            }
        }

        let popupVC = BottomPopupVC(contentViewController: socialNetworksVC)
        popupVC.preferredContentSize = .init(width: presenter?.view.frame.width ?? 0, height: 200)
        presenter?.present(popupVC, animated: true, completion: nil)
    }

    func passwordRecoveryRequestHandler()
    {
        let recoverPasswordVC = dependencies.viewControllerFactory.createRecoverPasswordVC(params: .none)
        let xsollaSDK = dependencies.xsollaSDK

        recoverPasswordVC.actionButtonHandler =
        { (vc, senderView, formData) in

            vc.setState(.loading(senderView), animated: true)

            xsollaSDK.resetPassword(loginProjectId: AppConfig.loginProjectID,
                                    username: formData.username,
                                    loginUrl: AppConfig.redirectURL)
            { result in
                switch result
                {
                    case .success: do
                    {
                        vc.setState(.normal, animated: true)
                        logger.debug { "Password recovery mail was sent." }
                        self.showPasswordRecoveryAlert()
                    }

                    case .failure(let error): logger.error { error }
                }
            }
        }

        recoverPasswordVC.miscButtonHandler =
        { [weak self] (_, _) in
            self?.popViewController(animated: true)
        }

        pushViewController(recoverPasswordVC)
    }

    // MARK: - Private

    /// Opens web browser with a link for performing social authentication.
    private func startSocialAuthSession(url: URL)
    {
        let webVC = dependencies.viewControllerFactory.createWebBrowserVC(params: url)
        let webRedirectHandler = WebRedirectHandler()

        webRedirectHandler.onRedirect =
        { [weak webVC, weak self] url in
            if url.absoluteString.starts(with: AppConfig.redirectURL)
            {
                webVC?.dismiss(animated: true, completion: nil)

                if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let authCode = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value
                {
                    self?.handleAuthCode(authCode)
                }

                return .cancel
            }
            return .allow
        }

        webVC.navigationDelegate = webRedirectHandler
        self.webRedirectHandler = webRedirectHandler

        presenter?.present(webVC, animated: true, completion: nil)
    }

    /// Exchanges auth code for JWT token and saves it.
    private func handleAuthCode(_ authCode: String)
    {
        dependencies.xsollaSDK.generateJWT(grantType: .authorizationCode,
                                           clientId: AppConfig.loginClientId,
                                           refreshToken: nil,
                                           clientSecret: nil,
                                           redirectUri: AppConfig.redirectURL,
                                           authCode: authCode)
        { [weak self] result in guard let self = self else { return }
            switch result
            {
                case .success: self.onFinish?(self)
                case .failure(let error): logger.error { error }
            }
        }
    }

    private func showRegistrationSuccessAlert()
    {
        let alert = UIAlertController(title: L10n.Alert.Registration.Success.title,
                                      message: L10n.Alert.Registration.Success.message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: L10n.Alert.Action.ok, style: .default, handler: nil)
        alert.addAction(alertAction)
        presenter?.present(alert, animated: true, completion: nil)
    }

    private func showPasswordRecoveryAlert()
    {
        let alert = UIAlertController(title: L10n.Alert.PasswordRecover.Success.title,
                                      message: L10n.Alert.PasswordRecover.Success.message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: L10n.Alert.Action.ok, style: .default, handler: nil)
        alert.addAction(alertAction)
        presenter?.present(alert, animated: true, completion: nil)
    }
}

extension AuthenticationCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let xsollaSDK: XsollaSDKProtocol
    }

    typealias Params = EmptyParams
}
