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

public typealias InventoryKitResult<T> = Result<T, Error>
public typealias InventoryKitCompletion<T> = (InventoryKitResult<T>) -> Void

public final class InventoryKit
{
    public static let shared = InventoryKit()
    
    private var api: InventoryAPIProtocol
    
    convenience init()
    {
        let requestPerformer = XSDKNetwork(sessionConfiguration: XSDKNetwork.defaultSessionConfiguration)
        let responseProcessor = InventoryAPIResponseProcessor()
        let api = InventoryAPI(requestPerformer: requestPerformer, responseProcessor: responseProcessor)
        
        self.init(api: api)
    }
    
    init(api: InventoryAPIProtocol)
    {
        self.api = api
    }
}

extension InventoryKit
{
    /**
     Client method. Retrieves the current user’s inventory.
     - Parameters:
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - projectId: Project ID.
        - platform: Publishing platform the user plays on.
        - detailedSubscriptions: An option whether detailed subscriptions information is required.
        - completion: Completion with `Result`: Array of `InventoryItem` on success and `Error` on failure.
     */
    public func getUserInventoryItems(accessToken: String,
                                      projectId: Int,
                                      platform: String?,
                                      detailedSubscriptions: Bool? = false,
                                      completion: @escaping InventoryKitCompletion<[InventoryItem]>)
    {
        api.getUserInventoryItems(accessToken: accessToken, projectId: projectId, platform: platform)
        { [weak self] result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let items = responseModel.items.map { InventoryItem(fromAPIResponse: $0) }
                    
                    guard detailedSubscriptions == true else
                    {
                        completion(.success(items))
                        return
                    }
                    
                    self?.getDetailedUserSubscriptions(for: items,
                                                       accessToken: accessToken,
                                                       projectId: projectId,
                                                       platform: platform,
                                                       completion: completion)
                }
                
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }
    
    /**
     Client method. Retrieves the current user’s virtual balance.
     - Parameters:
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - projectId: Project ID.
        - platform: Publishing platform the user plays on.
        - completion: Completion with `Result`: Array of `InventoryVirtualCurrencyBalance` on success and `Error` on failure.
     */
    public func getUserVirtualCurrencyBalance(
        accessToken: String,
        projectId: Int,
        platform: String?,
        completion: @escaping InventoryKitCompletion<[InventoryVirtualCurrencyBalance]>)
    {
        api.getUserVirtualCurrencyBalance(accessToken: accessToken, projectId: projectId, platform: platform)
        { result in
            
            switch result
            {
                case .success(let responseModel): do
                {
                    let currenciesBalance = responseModel.items
                        .map { InventoryVirtualCurrencyBalance(fromAPIResponse: $0) }
                    completion(.success(currenciesBalance))
                }
                
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }
    
    /**
     Client method. Retrieves the current user’s subscriptions.
     - Parameters:
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - projectId: Project ID.
        - platform: Publishing platform the user plays on.
        - completion: Completion with `Result`: Array of `InventoryUserSubscription` on success and `Error` on failure.
     */
    public func getUserSubscriptions(accessToken: String,
                                     projectId: Int,
                                     platform: String?,
                                     completion: @escaping InventoryKitCompletion<[InventoryUserSubscription]>)
    {
        api.getUserSubscriptions(accessToken: accessToken,
                                 projectId: projectId,
                                 platform: platform)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let subscriptions = responseModel.items.map { InventoryUserSubscription(fromAPIResponse: $0) }
                    completion(.success(subscriptions))
                }
                    
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }
    
    /**
     Client Method. Consumes an item from the current user’s inventory.
     - Parameters:
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - projectId: Project ID.
        - platform: Publishing platform the user plays on.
        - consumingItem: Instance of `InventoryConsumingItem`.
        - completion: Completion with `Result`: success without content or failure with `Error`.
     */
    public func consumeItem(accessToken: String,
                            projectId: Int,
                            platform: String?,
                            consumingItem: InventoryConsumingItem,
                            completion: @escaping InventoryKitCompletion<Void>)
    {
        api.consumeItem(accessToken: accessToken,
                        projectId: projectId,
                        platform: platform,
                        consumingItem: consumingItem)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }
}

// MARK: - Helpers

extension InventoryKit
{
    private func getDetailedUserSubscriptions(for inventoryItems: [InventoryItem],
                                              accessToken: String,
                                              projectId: Int,
                                              platform: String?,
                                              completion: @escaping InventoryKitCompletion<[InventoryItem]>)
    {
        getUserSubscriptions(accessToken: accessToken,
                             projectId: projectId,
                             platform: platform)
        { result in
            
            switch result
            {
                case .success(let subscriptions): do
                {
                    let subscriptions = subscriptions.reduce(into: [:]) { $0[$1.sku] = $1 }
                    let items = inventoryItems.map { $0.withSubscriptionInfo(subscriptions[$0.sku]) }
                    
                    completion(.success(items))
                }
                
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }
}

private extension Error
{
    var processed: Error
    {
        if case .parameters(_, let model) = self as? APIError<InventoryAPIErrorModel>
        {
            return InventoryKitError(code: model?.code) ?? self
        }

        return self
    }
}

public enum InventoryKitError: Error
{
    internal init?(code: Int?)
    {
        switch code
        {
            default: return nil
        }
    }
}
