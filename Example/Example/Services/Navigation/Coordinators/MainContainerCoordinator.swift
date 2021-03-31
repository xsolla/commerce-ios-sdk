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
    
    var contentCoordinator: MainContentCoordinatorProtocol?
    var mainVC: MainVCProtocol?
    
    var currencyBalanceProvider: VirtualCurrencyBalanceProvider?
    var currentUserInfoProvider: CurrentUserInfoProvider?
    
    override func start()
    {
        let viewController: MainVCProtocol
        var contentNavigationController: NavigationController
        let contentCoordinator: MainContentCoordinatorProtocol
        
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
                                                                      params: .none)
            contentCoordinator.reloadRequestHandler = { [weak self] in self?.currencyBalanceProvider?.requestData() }
        }
        
        startChildCoordinator(contentCoordinator) { }
        contentCoordinator.show(screen: .inventory)
        
        self.contentCoordinator = contentCoordinator
        self.mainVC = viewController
        
        self.currencyBalanceProvider = getCurrencyBalanceProvider()
        self.currencyBalanceProvider?.delegate = mainVC
        
        self.currentUserInfoProvider = getCurrentUserInfoProvider()
        
        pushViewController(viewController, pushMode: .replaceCurrent)
        
        viewController.sideMenuRequestHandler = { [weak self] in self?.showMenu() }
        
        self.currentUserInfoProvider?.requestData()
        self.currencyBalanceProvider?.requestData()
    }

    // MARK: - Private
    
    var currentViewController: UIViewController? { presenter?.viewControllers.last }
    
    private func showMenu()
    {
        let factory = dependencies.viewControllerFactory

        let sideMenuContentVC = factory.createSideMenuContentVC(params: .none)
        let sideMenuVC = factory.createSideMenuVC(params: .init(contentViewController: sideMenuContentVC))
        
        let currentUserInfo = dependencies.xsollaSDK.currentUserInfo
        sideMenuContentVC.setProfileInfo(name: currentUserInfo?.nickname,
                                         email: currentUserInfo?.email,
                                         avatarUrl: URL(string: currentUserInfo?.picture ?? ""))
        
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
        
        presentViewController(sideMenuVC, animated: false, completion: nil)
    }
    
    private func getCurrencyBalanceProvider() -> VirtualCurrencyBalanceProvider?
    {
        let params = VirtualCurrencyBalanceProviderBuildParams(projectId: AppConfig.projectId)
        return dependencies.modelFactory.createVirtualCurrencyBalanceProvider(params: params)
    }
    
    private func getCurrentUserInfoProvider() -> CurrentUserInfoProvider?
    {
        return dependencies.modelFactory.createCurrentUserInfoProvider(params: .empty)
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
