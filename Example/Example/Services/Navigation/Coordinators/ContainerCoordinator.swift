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

protocol ContainerCoordinatorProtocol: Coordinator, Finishable
{
    var onLogout: (() -> Void)? { get set }
}

class ContainerCoordinator: BaseCoordinator<ContainerCoordinator.Dependencies,
                                            ContainerCoordinator.Params>,
                            ContainerCoordinatorProtocol
{
    var onLogout: (() -> Void)?
    var onHelp: (() -> Void)?
    
    weak var contentCoordinator: MainCoordinatorProtocol?
    weak var mainVC: MainVCProtocol?
    weak var sideMenuContentVC: SideMenuContentVCProtocol?
    weak var userProfile: UserProfileProtocol?

    override func start()
    {
        let viewController: MainVCProtocol
        var contentNavigationController: NavigationController
        let contentCoordinator: MainCoordinatorProtocol

        let loginAsyncUtility = dependencies.asyncUtilsFactory.createLoginAsyncUtils(params: .none)

        let userProfile = dependencies.modelFactory.createUserProfile(params: .init(asyncUtility: loginAsyncUtility))
        self.userProfile = userProfile
        
        do
        {
            let factory = dependencies.viewControllerFactory
            contentNavigationController = factory.createMainVCContentNavigationController()
            viewController = factory.createMainVC(params: .init(navigationController: contentNavigationController))
        }
        
        do
        {
            let factory = dependencies.coordinatorFactory

            let params = MainContentCoordinatorFactoryParams(userProfile: userProfile,
                                                             loginAsyncUtility: loginAsyncUtility)

            contentCoordinator = factory.createMainContentCoordinator(presenter: contentNavigationController,
                                                                      params: params)

            contentCoordinator.reloadRequestHandler =
            { [weak self] in

                self?.dependencies.xsollaSDK.requestBalanceUpdate()
            }
        }
        
        self.contentCoordinator = contentCoordinator
        self.mainVC = viewController
        
        self.dependencies.xsollaSDK.balanceUpdatesListener = mainVC

        viewController.sideMenuRequestHandler = { [weak self] in self?.showMenu() }
        viewController.addCurrencyHandler = { [weak self] in self?.showScreen(.virtualCurrency) }

        self.userProfile?.fetchUserDetails(completion: nil)
        self.userProfile?.addListener(self)

        self.dependencies.xsollaSDK.requestBalanceUpdate()

        if let deepLink = dependencies.deepLinkManager.deepLink, case .paymentCompletion = deepLink
        {
            dependencies.xsollaSDK.requestBalanceUpdate()
            showScreen(.inventory)
        }

        pushViewController(viewController, pushMode: .replaceCurrent)

        startChildCoordinator(contentCoordinator) { }
        showScreen(.userProfile)

        dependencies.deepLinkManager.addObserver(self)
    }

    // MARK: - Private
    
    // swiftlint:disable function_body_length
    private func showMenu()
    {
        let factory = dependencies.viewControllerFactory

        let sideMenuContentVC = factory.createSideMenuContentVC(params: .none)
        let sideMenuVC = factory.createSideMenuVC(params: .init(contentViewController: sideMenuContentVC))

        let message: String? = userProfile?.userDetails.flatMap
        { details in

            if details.email.nilIfEmpty != nil && details.isLastEmailConfirmed != true
            {
                return L10n.Profile.confirmEmailMessage
            }
            else if details.isAnonymous == true && details.email.nilIfEmpty == nil
            {
                return L10n.Profile.UpgradeMessage.profile
            }

            return nil
        }

        let currentUserInfo = userProfile?.userDetails
        sideMenuContentVC.setProfileInfo(name: currentUserInfo?.nickname,
                                         email: currentUserInfo?.email,
                                         avatarUrl: URL(string: currentUserInfo?.picture ?? ""),
                                         message: message)
        
        sideMenuContentVC.profileMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.showScreen(.userProfile)
        }
        
        sideMenuContentVC.inventoryMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.showScreen(.inventory)
        }
        
        sideMenuContentVC.virtualItemsMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.showScreen(.virtualItems)
        }
        
        sideMenuContentVC.virtualCurrencyMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.showScreen(.virtualCurrency)
        }

        sideMenuContentVC.characterMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.showScreen(.character)
        }

        sideMenuContentVC.webstoreMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.openWebstore()
        }
        
        sideMenuContentVC.logoutMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.onLogout?()
        }
        
        self.sideMenuContentVC = sideMenuContentVC
        
        presentViewController(sideMenuVC, animated: false, completion: nil)
    }
    // swiftlint:enable function_body_length

    private func showScreen(_ screen: MainCoordinator.Screen)
    {
        switch screen
        {
            case .userProfile:
                mainVC?.setBalanceView(visible: false)
                contentCoordinator?.show(screen: .userProfile)

            case .character:
                mainVC?.setBalanceView(visible: true)
                contentCoordinator?.show(screen: .character)

            case .inventory:
                mainVC?.setBalanceView(visible: true)
                contentCoordinator?.show(screen: .inventory)

            case .virtualCurrency:
                mainVC?.setBalanceView(visible: true)
                contentCoordinator?.show(screen: .virtualCurrency)

            case .virtualItems:
                mainVC?.setBalanceView(visible: true)
                contentCoordinator?.show(screen: .virtualItems)
        }
    }

    private func openWebstore()
    {
        guard var urlComponents = URLComponents(string: AppConfig.webshopUrl) else { return }

        dependencies.accessTokenProvider.getAccessToken
        { result in

            if case .success(let token) = result
            {
                let tokenQueryItem = URLQueryItem(name: "token", value: token)
                urlComponents.queryItems = [tokenQueryItem]

                if let url = urlComponents.url
                {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension ContainerCoordinator: UserProfileListener
{
    func userProfileDidUpdateDetails(_ userProfile: UserProfileProtocol)
    {
        guard let viewController = sideMenuContentVC, userProfile.state == .loaded else { return }

        let message = userProfile.userDetails.flatMap { $0.isAnonymous ? L10n.Profile.UpgradeMessage.menu : nil }

        let currentUserInfo = userProfile.userDetails
        viewController.setProfileInfo(name: currentUserInfo?.nickname,
                                      email: currentUserInfo?.email,
                                      avatarUrl: URL(string: currentUserInfo?.picture ?? ""),
                                      message: message)
    }
    
    func userProfileDidResetPassword()
    {
        logger.event { "User profile did send request to reset password" }
    }
}

extension ContainerCoordinator: DeepLinkManagerObserver
{
    func deepLinkManager(_ manager: DeepLinkManagerProtocol, didRegisterDeepLink deepLink: DeepLink)
    {
        if let deepLink = manager.deepLink, case .paymentCompletion = deepLink
        {
            dependencies.xsollaSDK.requestBalanceUpdate()
            showScreen(.inventory)
        }
    }
}

extension ContainerCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let xsollaSDK: XsollaSDKProtocol
        let asyncUtilsFactory: AsyncUtilsFactoryProtocol
        let accessTokenProvider: AccessTokenProvider
        let deepLinkManager: DeepLinkManagerProtocol
    }
    
    typealias Params = EmptyParams
}
