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
    var onHelp: (() -> Void)? { get set }
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
        
        let userProfile = dependencies.modelFactory.createUserProfile(params: .none)
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
            contentCoordinator = factory.createMainContentCoordinator(presenter: contentNavigationController,
                                                                      params: .init(userProfile: userProfile))
            contentCoordinator.reloadRequestHandler = { [weak self] in self?.currencyBalanceProvider?.requestData() }
        }
        
        startChildCoordinator(contentCoordinator) { }
        contentCoordinator.show(screen: .character)
        
        self.contentCoordinator = contentCoordinator
        self.mainVC = viewController
        
        self.currencyBalanceProvider = getCurrencyBalanceProvider()
        self.currencyBalanceProvider?.delegate = mainVC
        
        pushViewController(viewController, pushMode: .replaceCurrent)
        
        viewController.sideMenuRequestHandler = { [weak self] in self?.showMenu() }
        
        self.userProfile?.fetchUserDetails(completion: nil)
        self.userProfile?.addListener(self)
        self.currencyBalanceProvider?.requestData()
    }

    // MARK: - Private
    
    var currentViewController: UIViewController? { presenter?.viewControllers.last }
    
    private func showMenu()
    {
        let factory = dependencies.viewControllerFactory

        let sideMenuContentVC = factory.createSideMenuContentVC(params: .none)
        let sideMenuVC = factory.createSideMenuVC(params: .init(contentViewController: sideMenuContentVC))
        
        let currentUserInfo = userProfile?.userDetails
        sideMenuContentVC.setProfileInfo(name: currentUserInfo?.nickname,
                                         email: currentUserInfo?.email,
                                         avatarUrl: URL(string: currentUserInfo?.picture ?? ""))
        
        sideMenuContentVC.profileMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.contentCoordinator?.show(screen: .account)
        }
        
        sideMenuContentVC.inventoryMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.contentCoordinator?.show(screen: .inventory)
        }
        
        sideMenuContentVC.virtualItemsMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.contentCoordinator?.show(screen: .virtualItems)
        }
        
        sideMenuContentVC.virtualCurrencyMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.contentCoordinator?.show(screen: .virtualCurrency)
        }

        sideMenuContentVC.characterMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.contentCoordinator?.show(screen: .character)
        }
        
        sideMenuContentVC.helpMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.onHelp?()
        }
        
        sideMenuContentVC.logoutMenuItemHandler =
        { [weak self, unowned sideMenuVC] in
            sideMenuVC.hide(animated: true)
            self?.onLogout?()
        }
        
        self.sideMenuContentVC = sideMenuContentVC
        
        presentViewController(sideMenuVC, animated: false, completion: nil)
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
        
        let avatarURL = URL(string: userProfile.userDetails?.picture ?? "")
        viewController.setProfileInfo(name: userProfile.userDetails?.nickname,
                                      email: userProfile.userDetails?.email,
                                      avatarUrl: avatarURL)
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
    }
    
    typealias Params = EmptyParams
}
