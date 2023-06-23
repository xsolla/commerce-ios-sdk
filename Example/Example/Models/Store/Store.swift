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
    func purchase(itemSku: String,
                  withCurrencySku currencySku: String, 
                  completion: @escaping (Result<Int, Error>) -> Void)
    {
        dependencies.xsollaSDK.purchaseItemByVirtualCurrency(projectId: AppConfig.projectId,
                                                             itemSKU: itemSku,
                                                             virtualCurrencySKU: currencySku,
                                                             platform: nil,
                                                             customParameters: nil,
                                                             completion: completion)
    }
    
    func purchaseFreeItem(itemSKU: String,
                          completion: @escaping (Result<Int, Error>) -> Void)
    {
        
        dependencies.xsollaSDK.purchaseFreeItem(projectId: AppConfig.projectId,
                                                itemSKU: itemSKU,
                                                quantity: 1,
                                                customParameters: nil,
                                                completion: completion)
    }
    
    func createOrder(itemSKU: String,
                     quantity: Int = 1,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     completion: @escaping (Result<StoreOrderPaymentInfo, Error>) -> Void)
    {

        let uiSettings = StorePaymentProjectSettings.UISettings(theme: AppConfig.paystationUITheme,
                                                                size: AppConfig.paystationUISize)
        let redirectPolicy =
            StorePaymentProjectSettings.RedirectPolicy(redirectConditions: .any,
                                                       delay: 5,
                                                       statusForManualRedirection: .any,
                                                       redirectButtonCaption: L10n.Store.Params.backToTheGame)

        let paymentProjectSettings = StorePaymentProjectSettings(ui: uiSettings,
                                                                 returnUrl: AppConfig.paymentsRedirectURL,
                                                                 redirectPolicy: redirectPolicy)

        dependencies.xsollaSDK.createOrder(projectId: AppConfig.projectId,
                                           itemSKU: itemSKU,
                                           quantity: quantity,
                                           currency: currency,
                                           locale: locale,
                                           isSandbox: isSandbox,
                                           paymentProjectSettings: paymentProjectSettings,
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
