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
import XsollaSDKInventoryKit
import Promises

class VirtualItemsList
{
    let dependencies: Dependencies
    
    func requestData()
    {
        dependencies.loadStateListener.setState(.loading(nil), animated: true)
        
        Promises.all(getInventory(), getBundles(), getVirtualItems()).then
        { inventory, bundles, items in
            
            DispatchQueue.main.async
            {
                self.dependencies.dataSource.setup(bundles: bundles, items: items, inventory: inventory)
                self.dependencies.loadStateListener.setState(.normal, animated: true)
            }
        }
        .catch
        { error in
            logger.error { error }
            self.dependencies.loadStateListener.setState(.error(nil), animated: true)
        }
    }
    
    init(dependencies: Dependencies)
    {
        self.dependencies = dependencies
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }
    
    private func getInventory() -> Promise<[InventoryItem]>
    {
        Promise<[InventoryItem]>
        { fulfill, reject in
            
            self.dependencies.xsollaSDK.getUserInventoryItems(projectId: AppConfig.projectId,
                                                              platform: nil,
                                                              detailedSubscriptions: nil)
            { result in
                
                switch result
                {
                    case .success(let items): fulfill(items)
                    case .failure(let error): reject(error)
                }
            }
        }
    }
    
    private func getBundles() -> Promise<[StoreBundle]>
    {
        Promise<[StoreBundle]>
        { fulfill, reject in
            
            self.dependencies.xsollaSDK.getBundlesList(projectId: AppConfig.projectId, filterParams: .empty)
            { result in
                
                switch result
                {
                    case .success(let items): fulfill(items)
                    case .failure(let error): reject(error)
                }
            }
        }
    }
    
    private func getVirtualItems() -> Promise<[StoreVirtualItem]>
    {
        Promise<[StoreVirtualItem]>
        { fulfill, reject in
            
            self.dependencies.xsollaSDK.getVirtualItems(projectId: AppConfig.projectId, filterParams: .empty)
            { result in
                
                switch result
                {
                    case .success(let items): fulfill(items)
                    case .failure(let error): reject(error)
                }
            }
        }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}

extension VirtualItemsList
{
    struct Dependencies
    {
        let loadStateListener: LoadStatable
        let dataSource: VirtualItemsListDatasource
        let xsollaSDK: XsollaSDKProtocol
    }
}
