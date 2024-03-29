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

        viewController.appDeveloperSettingsRequestHandler =
        { [weak self] in
            logger.info(.ui, domain: .example) { "Auth coordinator - appDeveloperSettingsRequestHandler" }
            self?.appDeveloperSettingsRequestHandler()
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
            self.showError(error)
            logger.error { error }
        }
    }

    func loginDemoUserRequestHandler(in viewController: AuthenticationOptionsVCProtocol)
    {
        viewController.setState(.loading(nil), animated: true)

        dependencies.xsollaSDK.createDemoUser { [weak self] result in guard let self = self else { return }

            DispatchQueue.main.async
            {
                if case .success(let tokenInfo) = result
                {
                    viewController.setState(.normal, animated: true)
                    self.dependencies.loginManager.login(tokenInfo: tokenInfo)
                    self.onFinish?(self)
                }

                if case .failure(let error) = result
                {
                    logger.error { error }
                    viewController.setState(.error(nil), animated: true)
                    self.showError(error)
                }
            }
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
    
    func loginXsollaWidgetRequestHandler(in viewController: AuthenticationOptionsVCProtocol)
    {
        if #available(iOS 13.4, *)
        {
            loginXsollaWidgetAuthenticationSessionFlow(forVC: viewController)
        }
        else
        {
            loginXsollaWidgetLegacyFlow(forVC: viewController)
        }
    }

    func signupRequestHandler(formData: SignupFormData, forVC viewController: SignupVCProtocol, sender: UIView)
    {
        viewController.setState(.loading(sender), animated: true)

        let params = RegisterNewUserParams(username: formData.username,
                                           password: formData.password,
                                           email: formData.email,
                                           acceptConsent: nil,
                                           fields: nil,
                                           promoEmailAgreement: nil)

        let oAuth2Params = OAuth2Params(clientId: AppConfig.oAuth2ClientId,
                                        state: UUID().uuidString,
                                        scope: "offline",
                                        redirectUri: AppConfig.redirectUrl)

        let jwtParams = JWTGenerationParams(clientId: AppConfig.oAuth2ClientId, redirectUri: AppConfig.redirectUrl)

        dependencies.xsollaSDK.registerNewUser(params: params, oAuth2Params: oAuth2Params, jwtParams: jwtParams)
        { [weak self, weak viewController] result in guard let self = self else { return }

            if case .success(let tokenInfo) = result
            {
                viewController?.setState(.normal, animated: true)

                if let tokenInfo = tokenInfo
                {
                    self.dependencies.loginManager.login(tokenInfo: tokenInfo)
                    self.onFinish?(self)
                }
                else
                {
                    logger.info { "Registration info was sent to email." }
                    self.showRegistrationSuccessAlert()
                }

                self.onFinish?(self)
            }

            if case .failure(let error) = result
            {
                viewController?.setState(.error(nil), animated: true)
                logger.error { error }
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

    func appDeveloperSettingsRequestHandler()
    {
        let viewController = dependencies.viewControllerFactory.createAppDeveloperSettingsVC(params: .init())

        viewController.actionButtonHandler =
        { [weak self] viewController in
            self?.popViewController()

            AppConfig.setLoginId(viewController.model.loginId)
            AppConfig.setProjectId(Int(viewController.model.projectId))
            AppConfig.setOAuth2ClientId(Int(viewController.model.oAuthClientId))
            AppConfig.setWebshopUrl(viewController.model.webshopUrl)
        }

        viewController.resetButtonHandler =
        { [weak self] in
            self?.popViewController()

            AppConfig.resetToDefaults()
        }

        pushViewController(viewController)
    }

    @available(iOS 13.4, *)
    func loginSocialNetworkAuthenticationSessionFlow(network: SocialNetwork, forVC viewController: LoginVCProtocol)
    {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        logger.info(.ui, domain: .example) { "Auth coordinator - loginSocialNetworkAuthenticationSessionFlow \(network.rawValue)" }

        let oauthParams = OAuth2Params(clientId: AppConfig.oAuth2ClientId,
                                state: UUID().uuidString,
                                scope: "offline",
                                redirectUri: AppConfig.customSchemeRedirectUrl)

        let jwtParams = JWTGenerationParams(clientId: AppConfig.oAuth2ClientId,
                                            redirectUri: AppConfig.customSchemeRedirectUrl)

        let presentationContextProvider = WebAuthenticationPresentationContextProvider(presentationAnchor: window)

        dependencies.xsollaSDK.authBySocialNetwork(network.rawValue,
                                                   oAuth2Params: oauthParams,
                                                   jwtParams: jwtParams,
                                                   presentationContextProvider: presentationContextProvider)
        { [weak self] result in

            guard let self = self else { return }

            if case .success(let tokenInfo) = result { self.dependencies.loginManager.login(tokenInfo: tokenInfo) }
        }
    }
    
    @available(iOS 13.4, *)
    func loginXsollaWidgetAuthenticationSessionFlow(forVC viewController: AuthenticationOptionsVCProtocol)
    {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        logger.info(.ui, domain: .example) { "Auth coordinator - loginXsollaWidgetAuthenticationSessionFlow" }

        let oauthParams = OAuth2Params(clientId: AppConfig.oAuth2ClientId,
                                state: UUID().uuidString,
                                scope: "offline",
                                redirectUri: AppConfig.customSchemeRedirectUrl)

        let presentationContextProvider = WebAuthenticationPresentationContextProvider(presentationAnchor: window)

        dependencies.xsollaSDK.authWithXsollaWidget(oAuth2Params: oauthParams,
                                                    presentationContextProvider: presentationContextProvider)
        { [weak self] result in

            guard let self = self else { return }

            if case .success(let tokenInfo) = result { self.dependencies.loginManager.login(tokenInfo: tokenInfo) }
        }
    }

    func loginSocialNetworkCustomSchemeFlow(network: SocialNetwork, forVC viewController: LoginVCProtocol)
    {
        logger.info(.ui, domain: .example) { "Auth coordinator - loginSocialNetworkCustomSchemeFlow \(network.rawValue)" }
    }

    func loginSocialNetworkLegacyFlow(network: SocialNetwork, forVC viewController: LoginVCProtocol)
    {
        logger.info(.ui, domain: .example) { "Auth coordinator - loginSocialNetworkLegacyFlow \(network.rawValue)" }

        viewController.setState(.loading(nil), animated: true)
        dependencies.xsollaSDK.getLinkForSocialAuth(providerName: network.rawValue,
                                                    oAuth2Params: .init(clientId: AppConfig.oAuth2ClientId,
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
    
    func loginXsollaWidgetLegacyFlow(forVC viewController: AuthenticationOptionsVCProtocol)
    {
        logger.info(.ui, domain: .example) { "Auth coordinator - loginXsollaWidgetLegacyFlow " }

        viewController.setState(.loading(nil), animated: true)
        self.startXsollaWidgetAuthSession()
    }
    
    func loginSocialNetworkRequestHandler(network: SocialNetwork, forVC viewController: LoginVCProtocol)
    {
        if #available(iOS 13.4, *)
        {
            loginSocialNetworkAuthenticationSessionFlow(network: network, forVC: viewController)
        }
        else
        {
            loginSocialNetworkLegacyFlow(network: network, forVC: viewController)
        }
    }
    
    func moreSocialNetworksRequestHandler(forVC viewController: LoginVCProtocol)
    {
        let socialNetworksList =
            dependencies.modelFactory.createSocialNetworksList(params: .init(socialNetworks: SocialNetwork.allCases))
        
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

            xsollaSDK.resetPassword(loginProjectId: AppConfig.loginId,
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
            case .xsollaWidget: loginXsollaWidgetRequestHandler(in: viewController)
            
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

                switch LoginKit.shared.authCodeExtractor.extract(from: url)
                {
                    case .success(let code): self?.performAuthentication(withAuthCode: code)
                    case .failure(let error): self?.showError(error)
                }

                return .cancel
            }
            return .allow
        }

        webVC.navigationDelegate = webRedirectHandler
        self.webRedirectHandler = webRedirectHandler

        presenter?.present(webVC, animated: true, completion: nil)
    }

    /// Opens web browser with a link for xsolla widget authentication.
    private func startXsollaWidgetAuthSession()
    {
        let stringUrl = "https://login-widget.xsolla.com/latest/?projectId=\(AppConfig.loginId)&login_url=\(AppConfig.customSchemeRedirectUrl)"
        let url = URL(string: stringUrl)

        let webVC = dependencies.viewControllerFactory.createWebBrowserVC(params: url)
        let webRedirectHandler = WebRedirectHandler()

        webRedirectHandler.onRedirect =
        { [weak webVC, weak self] url in

            if url.absoluteString.starts(with: AppConfig.customSchemeRedirectUrl)
            {
                webVC?.dismiss(animated: true, completion: nil)

                switch LoginKit.shared.authTokenExtractor.extract(from: url)
                {
                    case .success(let token):
                        self?.dependencies.loginManager.login(accessToken: token,
                                                              refreshToken: "",
                                                              expireDate: Date(timeIntervalSinceNow: TimeInterval(3600)))
                    case .failure(let error): self?.showError(error)
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
        let alertAction = UIAlertAction(title: L10n.Alert.Action.ok, style: .default)
        { _ in
            self.onFinish?(self)
        }

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
