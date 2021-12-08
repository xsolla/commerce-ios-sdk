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

protocol MainCoordinatorProtocol: Coordinator, Finishable
{
    var reloadRequestHandler: (() -> Void)? { get set }
    
    func show(screen: MainCoordinator.Screen)
}

class MainCoordinator: BaseCoordinator<MainCoordinator.Dependencies, MainCoordinator.Params>,
                       MainCoordinatorProtocol
{
    var reloadRequestHandler: (() -> Void)?

    func show(screen: Screen)
    {
        switchToScreen(screen)
    }
    
    // MARK: - Screens
    
    func showUserProfileScreen()
    {
        if childCoordinators.last is UserProfileCoordinatorProtocol { return }

        let dependencies =
            UserProfileCoordinator.Dependencies(coordinatorFactory: dependencies.coordinatorFactory,
                                                viewControllerFactory: dependencies.viewControllerFactory,
                                                datasourceFactory: dependencies.datasourceFactory,
                                                userProfile: dependencies.userProfile)

        let coordinator = UserProfileCoordinator(presenter: presenter,
                                                 dependencies: dependencies,
                                                 params: .init(loginAsyncUtility: params.loginAsyncUtility,
                                                               xsollaSDK: params.xsollaSDK))

        presenter?.setPushMode(.replaceAll)
        childCoordinators = []
        
        startChildCoordinator(coordinator, onFinish: nil)
    }

    func showCharacterScreen()
    {
        if childCoordinators.last is CharacterCoordinatorProtocol { return }

        let dependencies = CharacterCoordinator.Dependencies(coordinatorFactory: dependencies.coordinatorFactory,
                                                             viewControllerFactory: dependencies.viewControllerFactory,
                                                             datasourceFactory: dependencies.datasourceFactory,
                                                             modelFactory: dependencies.modelFactory,
                                                             userProfile: dependencies.userProfile)

        let coordinator = CharacterCoordinator(presenter: presenter,
                                               dependencies: dependencies,
                                               params: .init(xsollaSDK: params.xsollaSDK))

        presenter?.setPushMode(.replaceAll)
        childCoordinators = []

        startChildCoordinator(coordinator, onFinish: nil)
    }

    func showInventoryScreen()
    {
        if childCoordinators.last is InventoryCoordinatorProtocol { return }

        let dependencies = InventoryCoordinator.Dependencies(coordinatorFactory: dependencies.coordinatorFactory,
                                                             viewControllerFactory: dependencies.viewControllerFactory,
                                                             datasourceFactory: dependencies.datasourceFactory,
                                                             modelFactory: dependencies.modelFactory)

        let coordinator = InventoryCoordinator(presenter: presenter,
                                               dependencies: dependencies,
                                               params: .init(xsollaSDK: params.xsollaSDK))

        coordinator.reloadRequestHandler = reloadRequestHandler
        coordinator.paymentRequestHandler =
        { [weak self] paymentToken, isSandbox, completion in

            if AppConfig.useExternalBrowserForPayStation
            {
                self?.proceedWithPayment(paymentToken: paymentToken, isSandbox: isSandbox)
            }
            else
            {
                self?.showPaymentBrowser(paymentToken: paymentToken, isSandbox: isSandbox)
                {
                    completion?()
                }
            }
        }

        presenter?.setPushMode(.replaceAll)
        childCoordinators = []

        startChildCoordinator(coordinator)
    }

    func showVirtualItemsScreen()
    {
        if childCoordinators.last is VirtualItemsCoordinatorProtocol { return }

        let dependencies =
        VirtualItemsCoordinator.Dependencies(coordinatorFactory: dependencies.coordinatorFactory,
                                             viewControllerFactory: dependencies.viewControllerFactory,
                                             datasourceFactory: dependencies.datasourceFactory,
                                             modelFactory: dependencies.modelFactory,
                                             store: dependencies.store)

        let coordinator = VirtualItemsCoordinator(presenter: presenter,
                                                  dependencies: dependencies,
                                                  params: .none)

        coordinator.reloadRequestHandler = reloadRequestHandler
        coordinator.paymentRequestHandler =
        { [weak self] paymentToken, isSandbox, completion in

            if AppConfig.useExternalBrowserForPayStation
            {
                self?.proceedWithPayment(paymentToken: paymentToken, isSandbox: isSandbox)
            }
            else
            {
                self?.showPaymentBrowser(paymentToken: paymentToken, isSandbox: isSandbox)
                {
                    completion?()
                }
            }
        }

        presenter?.setPushMode(.replaceAll)
        childCoordinators = []

        startChildCoordinator(coordinator)
    }

    func showVirtualCurrencyScreen()
    {
        if childCoordinators.last is VirtualCurrencyCoordinatorProtocol { return }

        let dependencies =
            VirtualCurrencyCoordinator.Dependencies(coordinatorFactory: dependencies.coordinatorFactory,
                                                    viewControllerFactory: dependencies.viewControllerFactory,
                                                    datasourceFactory: dependencies.datasourceFactory,
                                                    modelFactory: dependencies.modelFactory)

        let coordinator = VirtualCurrencyCoordinator(presenter: presenter,
                                                     dependencies: dependencies,
                                                     params: .init(xsollaSDK: params.xsollaSDK))

        coordinator.paymentRequestHandler =
        { [weak self] paymentToken, isSandbox, completion in

            if AppConfig.useExternalBrowserForPayStation
            {
                self?.proceedWithPayment(paymentToken: paymentToken, isSandbox: isSandbox)
            }
            else
            {
                self?.showPaymentBrowser(paymentToken: paymentToken, isSandbox: isSandbox)
                {
                    completion?()
                }
            }
        }

        presenter?.setPushMode(.replaceAll)
        childCoordinators = []

        startChildCoordinator(coordinator)
    }

    // MARK: - Private
    
    private func switchToScreen(_ screen: Screen)
    {
        switch screen
        {
            case .userProfile: showUserProfileScreen()
            case .character: showCharacterScreen()
            case .inventory: showInventoryScreen()
            case .virtualItems: showVirtualItemsScreen()
            case .virtualCurrency: showVirtualCurrencyScreen()
        }
    }

    private func proceedWithPayment(paymentToken: String, isSandbox: Bool)
    {
        guard let url = params.xsollaSDK.createPaymentUrl(paymentToken: paymentToken, isSandbox: isSandbox)
        else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showPaymentBrowser(paymentToken: String, isSandbox: Bool, onSuccessCompletion: (() -> Void)? = nil)
    {
        let xsollaSDK = params.xsollaSDK
        let paystationVC = PaystationVC()

        paystationVC.onSuccessPurchase =
        { vc in

            xsollaSDK.requestBalanceUpdate()
            vc.dismiss(animated: true, completion: nil)

            onSuccessCompletion?()
        }
        
        paystationVC.configuration = .init(paymentToken: paymentToken,
                                           redirectURL: AppConfig.paymentsRedirectURL,
                                           isSandbox: isSandbox)
        
        paystationVC.modalPresentationStyle = .formSheet
        presenter?.present(paystationVC, animated: true, completion: nil)
    }
}

extension MainCoordinator
{
    enum Screen
    {
        case userProfile
        case character
        case inventory
        case virtualItems
        case virtualCurrency
    }
}

extension MainCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let asyncUtilsFactory: AsyncUtilsFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let store: StoreProtocol
        let userProfile: UserProfileProtocol
    }

    struct Params
    {
        let loginAsyncUtility: LoginAsyncUtilityProtocol
        let xsollaSDK: XsollaSDKProtocol
    }
}
