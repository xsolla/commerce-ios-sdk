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

import Foundation
import XsollaSDKStoreKit

class VirtualCurrencyList
{
    let dependencies: Dependencies
    
    var orderPaymentHandler: ((StoreOrderPaymentInfo) -> Void)?
    
    func requestData()
    {
        dependencies.loadStateListener.setState(.loading(nil), animated: true)
        
        dependencies.xsollaSDK.getVirtualCurrencyPackages(projectId: AppConfig.projectId,
                                                          filterParams: .empty)
        { [weak self] result in
            
            guard let self = self else { return }
            
            switch result
            {
                case .success(let model): do
                {
                    self.dependencies.dataSource.set(items: model)
                    self.dependencies.loadStateListener.setState(.normal, animated: true)
                }
                
                case .failure(let error): do
                {
                    logger.error { error }
                    self.dependencies.loadStateListener.setState(.error(nil), animated: true)
                }
            }
        }
    }
    
    private func setupDataSource()
    {
        dependencies.dataSource.itemActionHandler =
        { [weak self] action, item in
            
            if action == .buy { self?.handleBuyAction(item: item) }
        }
    }
    
    private func handleBuyAction(item: VirtualCurrencyListDatasource.Item)
    {
        logger.info { "Buy action for item: \(item.name)" }
        
        dependencies.xsollaSDK.createOrder(projectId: AppConfig.projectId,
                                           itemSKU: item.sku,
                                           currency: nil,
                                           locale: nil,
                                           isSandbox: true,
                                           paymentProjectSettings: nil,
                                           customParameters: nil)
        { [weak self] result in
            switch result
            {
                case .success(let createdOrder): do
                {
                    self?.orderPaymentHandler?(createdOrder)
                }
                
                case .failure(let error): logger.error { error }
            }
        }
    }
    
    init(dependencies: Dependencies)
    {
        self.dependencies = dependencies
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
        
        setupDataSource()
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}

extension VirtualCurrencyList
{
    struct Dependencies
    {
        let loadStateListener: LoadStatable
        let dataSource: VirtualCurrencyListDatasource
        let xsollaSDK: XsollaSDKProtocol
    }
}
