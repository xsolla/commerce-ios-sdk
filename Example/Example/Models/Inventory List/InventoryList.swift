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
import XsollaSDKInventoryKit
import XsollaSDKStoreKit

class InventoryList
{
    let dependencies: Dependencies
    
    var orderPaymentHandler: ((StoreOrderPaymentInfo) -> Void)?
    
    func requestData()
    {
        dependencies.loadStateListener.setState(.loading(nil), animated: true)
        
        dependencies.xsollaSDK.getUserInventoryItems(projectId: AppConfig.projectId,
                                                     platform: "",
                                                     detailedSubscriptions: true)
        { [weak self] result in
            
            guard let self = self else { return }
            
            switch result
            {
                case .success(let items): do
                {
                    let items = items.compactMap
                    {
                        $0.type == .virtualGood ? InventoryListDataSource.Item(inventoryKitItem: $0) : nil
                    }
                    self.dependencies.dataSource.setup(items: items)
                    self.dependencies.loadStateListener.setState(.normal, animated: true)
                    logger.info(.common, domain: .inventoryKit) { result }
                }
                
                case .failure(let error): do
                {
                    self.dependencies.loadStateListener.setState(.error(nil), animated: true)
                    logger.error(.common, domain: .inventoryKit) { error }
                }
            }
        }
    }
    
    private func handleBuyAgainAction(for item: InventoryListDataSource.Item)
    {
        logger.info { "Buy item: \(item.name)" }

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
    
    private func handleConsumeAction(for item: InventoryListDataSource.Item)
    {
        logger.info { "Consume item: \(item.name)" }
        
        dependencies.loadStateListener.setState(.loading(nil), animated: true)
        
        consumeItem(item)
        { [weak self] result in
            
            switch result
            {
                case .success: self?.requestData()
                case .failure: self?.dependencies.loadStateListener.setState(.error(nil), animated: true)
            }
        }
    }
    
    private func setupDataSource()
    {
        dependencies.dataSource.itemActionHandler =
        { [weak self] action, item in

            switch action
            {
                case .consume: self?.handleConsumeAction(for: item)
                case .buyAgain: self?.handleBuyAgainAction(for: item)
                    
                default: break
            }
        }
    }
    
    init(dependencies: Dependencies)
    {
        self.dependencies = dependencies
        setupDataSource()

        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
    
    private func consumeItem(_ item: InventoryListDataSource.Item, completion: ((Result<Void, Error>) -> Void)?)
    {
        let consumingItem = InventoryConsumingItem(sku: item.sku,
                                                   quantity: item.instanceId == nil ? 1 : nil ,
                                                   instanceId: item.instanceId)
        
        dependencies.xsollaSDK.consumeItem(projectId: AppConfig.projectId,
                                           platform: nil,
                                           consumingItem: consumingItem)
        { result in
            
            switch result
            {
                case .success: completion?(.success(()))
                case .failure(let error): completion?(.failure(error))
            }
        }
    }
}

extension InventoryList
{
    struct Dependencies
    {
        let loadStateListener: LoadStatable
        let dataSource: InventoryListDataSource
        let xsollaSDK: XsollaSDKProtocol
    }
}
