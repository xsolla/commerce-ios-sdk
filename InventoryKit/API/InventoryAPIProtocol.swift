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

typealias InventoryAPIError = Error
typealias InventoryAPIResult<T> = Result<T, InventoryAPIError>

protocol InventoryAPIProtocol
{
    func getUserInventoryItems(accessToken: String,
                               projectId: Int,
                               platform: String?,
                               completion: @escaping (InventoryAPIResult<GetUserInventoryItemsResponse>) -> Void)
    
    func getUserVirtualCurrencyBalance(
        accessToken: String,
        projectId: Int,
        platform: String?,
        completion: @escaping (InventoryAPIResult<GetUserVirtualCurrencyBalanceResponse>) -> Void)
    
    func getUserSubscriptions(accessToken: String,
                              projectId: Int,
                              platform: String?,
                              completion: @escaping (InventoryAPIResult<GetUserSubscriptionsResponse>) -> Void)
    
    func consumeItem(accessToken: String,
                     projectId: Int,
                     platform: String?,
                     consumingItem: InventoryConsumingItem,
                     completion: @escaping (InventoryAPIResult<APIEmptyResponse>) -> Void)
}
