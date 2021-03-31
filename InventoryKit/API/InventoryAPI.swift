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
import XsollaSDKUtilities

class InventoryAPI
{
    let requestPerformer: RequestPerformer
    let responseProcessor: ResponseProcessor
    
    init(requestPerformer: RequestPerformer, responseProcessor: ResponseProcessor)
    {
        logger.debug(.initialization, domain: .inventoryKit) { String(describing: Self.self) }
        
        self.requestPerformer = requestPerformer
        self.responseProcessor = responseProcessor
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .inventoryKit) { deinitingType }
    }
}

extension InventoryAPI: InventoryAPIProtocol
{
    func getUserInventoryItems(accessToken: String,
                               projectId: Int,
                               platform: String?,
                               completion: @escaping (InventoryAPIResult<GetUserInventoryItemsResponse>) -> Void)
    {
        GetUserInventoryItemsAPIProxy(configuration).getUserInventoryItems(accessToken: accessToken,
                                                                           projectId: projectId,
                                                                           platform: platform,
                                                                           completion: completion)
    }
    
    func getUserVirtualCurrencyBalance(
        accessToken: String,
        projectId: Int,
        platform: String?,
        completion: @escaping (InventoryAPIResult<GetUserVirtualCurrencyBalanceResponse>) -> Void)
    {
        GetUserVirtualCurrencyBalanceAPIProxy(configuration).getUserVirtualCurrencyBalance(accessToken: accessToken,
                                                                                           projectId: projectId,
                                                                                           platform: platform,
                                                                                           completion: completion)
    }
    
    func getUserSubscriptions(accessToken: String,
                              projectId: Int,
                              platform: String?,
                              completion: @escaping (InventoryAPIResult<GetUserSubscriptionsResponse>) -> Void)
    {
        GetUserSubscriptionsAPIProxy(configuration).getUserSubscriptions(accessToken: accessToken,
                                                                         projectId: projectId,
                                                                         platform: platform,
                                                                         completion: completion)
    }
    
    func consumeItem(accessToken: String,
                     projectId: Int,
                     platform: String?,
                     consumingItem: InventoryConsumingItem,
                     completion: @escaping (InventoryAPIResult<APIEmptyResponse>) -> Void)
    {
        ConsumeItemAPIProxy(configuration).consumeItem(accessToken: accessToken,
                                                       projectId: projectId,
                                                       platform: platform,
                                                       consumingItem: consumingItem,
                                                       completion: completion)
    }
}

extension InventoryAPI
{
    var configuration: InventoryAPIConfiguration
    {
        InventoryAPIConfiguration(requestPerformer: requestPerformer,
                                  responseProcessor: responseProcessor,
                                  apiBasePath: "https://store.xsolla.com/api")
    }
}
