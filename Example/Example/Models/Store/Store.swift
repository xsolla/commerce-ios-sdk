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

class Store: StoreProtocol
{
    func purchase(itemSku: String, withCurrencySku currencySku: String, completion: @escaping StoreKitCompletion<Int>)
    {
        dependencies.xsollaSDK.purchaseItemByVirtualCurrency(projectId: AppConfig.projectId,
                                                             itemSKU: itemSku,
                                                             virtualCurrencySKU: currencySku,
                                                             platform: nil,
                                                             customParameters: nil,
                                                             completion: completion)
    }
    
    func createOrder(itemSKU: String,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     completion: @escaping StoreKitCompletion<StoreOrderPaymentInfo>)
    {
        dependencies.xsollaSDK.createOrder(projectId: AppConfig.projectId,
                                           itemSKU: itemSKU,
                                           currency: currency,
                                           locale: locale,
                                           isSandbox: isSandbox,
                                           paymentProjectSettings: nil,
                                           customParameters: nil,
                                           completion: completion)
    }
    
    let dependencies: Dependencies

    init(dependencies: Dependencies)
    {
        self.dependencies = dependencies
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}

extension Store
{
    struct Dependencies
    {
        let xsollaSDK: XsollaSDKProtocol
    }
}
