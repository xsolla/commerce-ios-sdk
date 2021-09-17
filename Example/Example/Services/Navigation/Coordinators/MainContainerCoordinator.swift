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

protocol MainContainerCoordinatorProtocol: Coordinator, Finishable
{
    var onLogout: (() -> Void)? { get set }
}

class MainContainerCoordinator: BaseCoordinator<MainContainerCoordinator.Dependencies,
                                                MainContainerCoordinator.Params>,
                                MainContainerCoordinatorProtocol
{
    var onLogout: (() -> Void)?
    var onHelp: (() -> Void)?
    
    weak var contentCoordinator: MainContentCoordinatorProtocol?
    weak var mainVC: MainVCProtocol?
    weak var sideMenuContentVC: SideMenuContentVCProtocol?
    weak var userProfile: UserProfileProtocol?

    var currencyBalanceProvider: VirtualCurrencyBalanceProvider?
    
    override func start()
    {
        let viewController: MainVCProtocol
        var contentNavigationController: NavigationController
        let contentCoordinator: MainContentCoordinatorProtocol

        let params = LoginAsyncUtilsFactoryParams(clientId: AppConfig.loginClientId,
                                                  redirectURL: AppConfig.redirectUrl,
                                                  scope: AppConfig.defaultLoginScope)

        let loginAsyncUtility = dependencies.asyncUtilsFactory.createLoginAsyncUtils(params: params)

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

            contentCoordinator.reloadRequestHandler = { [weak self] in self?.currencyBalanceProvider?.requestData() }
        }
        
        self.contentCoordinator = contentCoordinator
        self.mainVC = viewController
        
        self.currencyBalanceProvider = getCurrencyBalanceProvider()
        self.currencyBalanceProvider?.delegate = mainVC

        viewController.sideMenuRequestHandler = { [weak self] in self?.showMenu() }
        viewController.addCurrencyHandler =
        { [weak self] in
            self?.mainVC?.setBalanceView(visible: true)
            self?.contentCoordinator?.show(screen: .virtualCurrency)
        }

        self.userProfile?.fetchUserDetails(completion: nil)
        self.userProfile?.addListener(self)
        self.currencyBalanceProvider?.requestData()

        startChildCoordinator(contentCoordinator) { }
        showScreen(.account)

        pushViewController(viewController, pushMode: .replaceCurrent)
    }

    // MARK: - Private
    
    var currentViewController: UIViewController? { presenter?.viewControllers.last }
    
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
            self?.showScreen(.account)
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
        
        sideMenuContentVC.logoutMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.onLogout?()
        }
        
        self.sideMenuContentVC = sideMenuContentVC
        
        presentViewController(sideMenuVC, animated: false, completion: nil)
    }

    private func showScreen(_ screen: MainContentCoordinator.Screen)
    {
        switch screen
        {
            case .account:
                mainVC?.setBalanceView(visible: false)
                contentCoordinator?.show(screen: .account)

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

    private func getCurrencyBalanceProvider() -> VirtualCurrencyBalanceProvider?
    {
        let params = VirtualCurrencyBalanceProviderBuildParams(projectId: AppConfig.projectId)
        return dependencies.modelFactory.createVirtualCurrencyBalanceProvider(params: params)
    }
}

extension MainContainerCoordinator: UserProfileListener
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

extension MainContainerCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let xsollaSDK: XsollaSDKProtocol
        let asyncUtilsFactory: AsyncUtilsFactoryProtocol
    }
    
    typealias Params = EmptyParams
}
