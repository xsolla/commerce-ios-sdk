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

protocol MainContentCoordinatorProtocol: Coordinator, Finishable
{
    var reloadRequestHandler: (() -> Void)? { get set }
    
    func show(screen: MainContentCoordinator.Screen)
}

class MainContentCoordinator: BaseCoordinator<MainContentCoordinator.Dependencies,
                                              MainContentCoordinator.Params>,
                              MainContentCoordinatorProtocol
{
    var reloadRequestHandler: (() -> Void)?
    var onLogout: (() -> Void)?
    
    // MARK: - Models
    
    private var inventoryList: InventoryList?
    private var virtualCurrencyList: VirtualCurrencyList?
    private var virtualItemsList: VirtualItemsList?
    private var virtualItemsActionHandler: VirtualItemsActionHandler?
    
    private func invalidateAllModels()
    {
        inventoryList = nil
        virtualCurrencyList = nil
        virtualItemsList = nil
        virtualItemsActionHandler = nil
    }

    func show(screen: Screen)
    {
        switchToScreen(screen)
    }
    
    // MARK: - Screens
    
    func showInventoryScreen()
    {
        if currentViewController is InventoryVCProtocol { return }

        invalidateAllModels()
        
        let dataSource = dependencies.datasourceFactory.createInventoryListDatasource(params: .none)
        
        let params = InventoryVCBuildParams(dataSource: dataSource)
        let viewController = dependencies.viewControllerFactory.createInventoryVC(params: params)
        
        let inventoryList =
            dependencies.modelFactory.createInventoryList(params: .init(loadStateListener: viewController,
                                                                        dataSource: dataSource))
        
        inventoryList.orderPaymentHandler =
        { [weak self] createdOrder in
            self?.showPaymentBrowser(paymentToken: createdOrder.paymentToken, isSandbox: createdOrder.isSandbox)
            {
                self?.inventoryList?.requestData()
            }
        }
        
        self.inventoryList = inventoryList
        
        inventoryList.requestData()
        
        pushViewController(viewController, pushMode: .replaceCurrent)
    }
    
    func showVirtualItemsScreen()
    {
        if currentViewController is VirtualItemsVCProtocol { return }
        
        invalidateAllModels()
        
        let dataSource = dependencies.datasourceFactory.createVirtualItemsListDatasource(params: .none)
        
        let viewController =
            dependencies.viewControllerFactory.createVirtualItemsVC(params: .init(dataSource: dataSource))
        
        let virtualItemsList =
            dependencies.modelFactory.createVirtualItemsList(params: .init(loadStateListener: viewController,
                                                                           dataSource: dataSource))
        self.virtualItemsList = virtualItemsList
        
        self.virtualItemsActionHandler =
            dependencies.modelFactory.createVirtualItemsActionHandler(params: .init(dataSource: dataSource,
                                                                                    viewController: viewController,
                                                                                    virtualItemsList: virtualItemsList,
                                                                                    store: dependencies.store))
        self.virtualItemsActionHandler?.bundlePreviewRequest =
        { [weak self] bundle in guard let self = self else { return }
            
            let bundleDataSource =
                self.dependencies.datasourceFactory.createBundlePreviewDataSource(params: .init(bundle: bundle))
            
            self.previewBundle(dataSource: bundleDataSource)
        }
        
        self.virtualItemsActionHandler?.reloadDataRequest =
        { [weak self, weak virtualItemsList] in
            
            virtualItemsList?.requestData()
            self?.reloadRequestHandler?()
        }
        
        self.virtualItemsActionHandler?.orderPaymentHandler =
        { [weak self] createdOrder in
            self?.showPaymentBrowser(paymentToken: createdOrder.paymentToken, isSandbox: createdOrder.isSandbox)
        }
        
        virtualItemsList.requestData()
        
        pushViewController(viewController, pushMode: .replaceCurrent)
    }
    
    func previewBundle(dataSource: BundlePreviewDataSource)
    {
        let viewController =
            dependencies.viewControllerFactory.createBundlePreviewVC(params: .init(dataSource: dataSource))
        
        presentViewController(viewController, completion: nil)
    }
    
    func showVirtualCurrencyScreen()
    {
        if currentViewController is VirtualCurrencyVCProtocol { return }
     
        invalidateAllModels()
        
        let dataSource = dependencies.datasourceFactory.createVirtualCurrencyListDatasource(params: .none)
        
        let viewController =
            dependencies.viewControllerFactory.createVirtualCurrencyVC(params: .init(dataSource: dataSource))
        
        let virtualCurrencyList =
            dependencies.modelFactory.createVirtualCurrencyList(params: .init(loadStateListener: viewController,
                                                                              dataSource: dataSource))
        
        virtualCurrencyList.orderPaymentHandler =
        { [weak self] createdOrder in
            
            self?.showPaymentBrowser(paymentToken: createdOrder.paymentToken, isSandbox: createdOrder.isSandbox)
            {
                self?.reloadRequestHandler?()
            }
        }
        
        self.virtualCurrencyList = virtualCurrencyList
        
        virtualCurrencyList.requestData()
        
        pushViewController(viewController, pushMode: .replaceCurrent)
    }
    
    // MARK: - Private
    
    var currentViewController: UIViewController? { presenter?.viewControllers.last }
    
    private func switchToScreen(_ screen: Screen)
    {
        switch screen
        {
            case .inventory: showInventoryScreen()
            case .virtualItems: showVirtualItemsScreen()
            case .virtualCurrency: showVirtualCurrencyScreen()
        }
    }
    
    private func showPaymentBrowser(paymentToken: String, isSandbox: Bool, onSuccessCompletion: (() -> Void)? = nil)
    {
        let paystationVC = PaystationVC()
        
        paystationVC.onSuccessPurchase =
        { vc in
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

extension MainContentCoordinator
{
    enum Screen
    {
        case inventory
        case virtualItems
        case virtualCurrency
    }
}

extension MainContentCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let store: StoreProtocol
    }
    
    typealias Params = EmptyParams
}
