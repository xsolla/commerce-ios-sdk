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
import XsollaSDKLoginKit

protocol AuthenticationCoordinatorProtocol: Coordinator, Finishable { }

class AuthenticationCoordinator: BaseCoordinator<AuthenticationCoordinator.Dependencies,
                                                 AuthenticationCoordinator.Params>,
                                 AuthenticationCoordinatorProtocol
{
    var webRedirectHandler: WebRedirectHandler?
    var loginAsync: LoginAsyncUtilityProtocol { dependencies.loginAsyncUtility }

    private var socialNetworksList: SocialNetworksListProtocol?

    override func start()
    {
        let viewController = dependencies.viewControllerFactory.createAuthenticationMainVC(params: .none)

        viewController.loginRequestHandler =
        { [weak self] viewController, sender, formData in
            logger.info(.ui, domain: .example) { "Auth coordinator - loginRequestHandler" }
            self?.loginUsernameRequestHandler(formData: formData, forVC: viewController, sender: sender)
        }

        viewController.authenticationOptionsRequestHandler =
        { [weak self] viewController, sender in
            logger.info(.ui, domain: .example) { "Auth coordinator - authenticationOptionsRequestHandler" }
            self?.authenticationOptionsRequestHandler()
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
            self?.loginSocialNetworkRequestHandler(network: network, forVC: vc)
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

    func loginUsernameRequestHandler(formData: LoginFormData, forVC viewController: LoginVCProtocol, sender: UIView)
    {
        viewController.setState(.loading(sender), animated: true)

        loginAsync.authWith(username: formData.username, password: formData.password).then
        { tokenInfo in

            viewController.setState(.normal, animated: true)
            self.dependencies.loginManager.login(tokenInfo: tokenInfo)
            self.onFinish?(self)
        }
        .catch
        { error in

            viewController.setState(.error(nil), animated: true)
            logger.error { error }
        }
    }

    func loginDemoUserRequestHandler(in viewController: AuthenticationOptionsVCProtocol)
    {
        viewController.setState(.loading(nil), animated: true)

        loginAsync.authWith(username: AppConfig.demoUsername, password: AppConfig.demoPassword).then
        { tokenInfo in

            viewController.setState(.normal, animated: true)
            self.dependencies.loginManager.login(tokenInfo: tokenInfo)
            self.onFinish?(self)
        }
        .catch
        { error in

            logger.error { error }
            viewController.setState(.error(nil), animated: true)
            self.showError(error)
        }
    }

    func loginDeviceIdRequestHandler(in viewController: AuthenticationOptionsVCProtocol)
    {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else { return }

        viewController.setState(.loading(nil), animated: true)

        loginAsync.authWith(deviceId: deviceId, device: UIDevice.current.name).then
        { tokenInfo in

            viewController.setState(.normal, animated: true)
            self.dependencies.loginManager.login(tokenInfo: tokenInfo)
            self.onFinish?(self)
        }
        .catch
        { error in

            logger.error { error }
            viewController.setState(.error(nil), animated: true)
            self.showError(error)
        }
    }

    func signupRequestHandler(formData: SignupFormData, forVC viewController: SignupVCProtocol, sender: UIView)
    {
        viewController.setState(.loading(sender), animated: true)

        dependencies.xsollaSDK.registerNewUser(oAuth2Params: .init(clientId: AppConfig.loginClientId,
                                                                   state: UUID().uuidString,
                                                                   scope: "offline",
                                                                   redirectUri: AppConfig.redirectUrl),
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

                    self.performAuthentication(withAuthCode: authCode)
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
        var lang = ""
        let systemLang = Locale.preferredLanguages[0].prefix(2)

        if ["de", "ko", "zh", "ja", "ru"].contains(systemLang)
        {
            lang = "/\(systemLang)"
        }

        let linkURL = URL(string: "https://xsolla.com\(lang)/privacypolicy")!
        UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
    }

    func loginSocialNetworkRequestHandler(network: SocialNetwork, forVC viewController: LoginVCProtocol)
    {
        logger.info(.ui, domain: .example) { "Auth coordinator - socialNetworkLoginRequestHandler \(network.rawValue)" }
        
        viewController.setState(.loading(nil), animated: true)
        dependencies.xsollaSDK.getLinkForSocialAuth(providerName: network.rawValue,
                                                    oauth2params: .init(clientId: AppConfig.loginClientId,
                                                                        state: UUID().uuidString,
                                                                        scope: "offline",
                                                                        redirectUri: AppConfig.redirectUrl))
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
        let socialNetworksList = dependencies.modelFactory
            .createSocialNetworksList(params: .init(socialNetworks: SocialNetwork.allCases))
        
        let socialNetworksListVC = dependencies.viewControllerFactory.createSocialNetworksListVC(params: .none)
        socialNetworksListVC.setup(rows: socialNetworksList.search(searchText: ""))
        
        socialNetworksListVC.onRowSelect =
        { [weak self, weak socialNetworksListVC] row in
            
            self?.socialNetworksList = nil
            socialNetworksListVC?.dismiss(animated: true)
            {
                self?.loginSocialNetworkRequestHandler(network: row.socialNetwork, forVC: viewController)
            }
        }
        
        socialNetworksListVC.onSearchTextEdit =
        { [weak self, weak socialNetworksListVC] searchText in

            socialNetworksListVC?.setup(rows: self?.socialNetworksList?.search(searchText: searchText) ?? [])
            socialNetworksListVC?.reloadView()
        }
        
        socialNetworksListVC.onDismiss = { [weak self] in self?.socialNetworksList = nil }
        
        self.socialNetworksList = socialNetworksList
        socialNetworksListVC.modalPresentationStyle = .overFullScreen
        presenter?.present(socialNetworksListVC, animated: true, completion: nil)
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
                                    loginUrl: AppConfig.redirectUrl)
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

    func authenticationOptionsRequestHandler()
    {
        let viewController = dependencies.viewControllerFactory.createAuthenticationOptionsVC(params: .init())

        viewController.loginRequestHandler =
        { [weak self] option in

            self?.handleAuthenticationOption(option, in: viewController)
        }

        pushViewController(viewController)
    }

    func handleAuthenticationOption(_ authenticationOption: AuthenticationOption,
                                    in viewController: AuthenticationOptionsVCProtocol)
    {
        switch authenticationOption
        {
            case .demoUser: loginDemoUserRequestHandler(in: viewController)
            case .email: startEmailAuthCoordinator(in: viewController)
            case .phone: startPhoneAuthCoordinator(in: viewController)
            case .deviceId: loginDeviceIdRequestHandler(in: viewController)
            
            default: break
        }

        logger.info(.ui) { "User did select AuthenticationOption: \(authenticationOption)" }
    }

    func startEmailAuthCoordinator(in viewController: AuthenticationOptionsVCProtocol)
    {
        let params = AuthenticationOTPCoordinatorFactoryParams(otpType: .email,
                                                               loginManager: dependencies.loginManager,
                                                               loginAsyncUtility: dependencies.loginAsyncUtility)

        let coordinator = dependencies.coordinatorFactory.createAuthenticationOTPCoordinator(presenter: presenter,
                                                                                             params: params)

        startChildCoordinator(coordinator)
        { [unowned self] in
            if dependencies.loginManager.userLogedIn { onFinish?(self) }
        }
    }

    func startPhoneAuthCoordinator(in viewController: AuthenticationOptionsVCProtocol)
    {
        let params = AuthenticationOTPCoordinatorFactoryParams(otpType: .phone,
                                                               loginManager: dependencies.loginManager,
                                                               loginAsyncUtility: dependencies.loginAsyncUtility)

        let coordinator = dependencies.coordinatorFactory.createAuthenticationOTPCoordinator(presenter: presenter,
                                                                                             params: params)

        startChildCoordinator(coordinator)
        { [unowned self] in
            if dependencies.loginManager.userLogedIn { onFinish?(self) }
        }
    }

    // MARK: - Private

    /// Opens web browser with a link for performing social authentication.
    private func startSocialAuthSession(url: URL)
    {
        let webVC = dependencies.viewControllerFactory.createWebBrowserVC(params: url)
        let webRedirectHandler = WebRedirectHandler()

        webRedirectHandler.onRedirect =
        { [weak webVC, weak self] url in
            if url.absoluteString.starts(with: AppConfig.redirectUrl)
            {
                webVC?.dismiss(animated: true, completion: nil)

                self?.loginAsync.extractAuthCode(redirectUrl: url.absoluteString).then
                {
                    self?.performAuthentication(withAuthCode: $0)
                }
                .catch
                {
                    self?.showError($0)
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
    private func performAuthentication(withAuthCode authCode: String)
    {
        loginAsync.generateJWTWith(authCode: authCode).then
        { tokenInfo in

            self.dependencies.loginManager.login(tokenInfo: tokenInfo)
            self.onFinish?(self)
        }
        .catch { error in logger.error { error } }
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

    func showError(_ error: Error)
    {
        guard let alertVC = createAlertViewController(with: error) else { return }
        presenter?.present(alertVC, animated: true, completion: nil)
    }

    func createAlertViewController(with error: Error) -> UIAlertController?
    {
        guard let error = parseError(error) else { return nil }

        let alertVC = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(action)

        return alertVC
    }

    func parseError(_ error: Error) -> (title: String?, message: String?)?
    {
        switch error
        {
            default: break
        }

        return ("Error", error.localizedDescription)
    }
}

extension AuthenticationCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let xsollaSDK: XsollaSDKProtocol
        let loginManager: LoginManagerProtocol
        let loginAsyncUtility: LoginAsyncUtilityProtocol
        let modelFactory: ModelFactoryProtocol
    }

    typealias Params = EmptyParams
}
