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

public final class InventoryKit
{
    public static let shared = InventoryKit()

    private var api: InventoryAPIProtocol
    private var modelFactory: ModelFactoryProtocol
    private var errorTranslator: ErrorTranslatorProtocol

    convenience init()
    {
        let requestPerformer = XSDKNetwork(sessionConfiguration: XSDKNetwork.defaultSessionConfiguration)
        let responseProcessor = InventoryAPIResponseProcessor()
        let api = InventoryAPI(requestPerformer: requestPerformer, responseProcessor: responseProcessor)
        let modelFactory = InventoryKitModelFactory()
        let errorTranslator = InventoryKitErrorTranslator()

        self.init(api: api, modelFactory: modelFactory, errorTranslator: errorTranslator)
    }

    init(api: InventoryAPIProtocol, modelFactory: ModelFactoryProtocol, errorTranslator: ErrorTranslatorProtocol)
    {
        self.api = api
        self.modelFactory = modelFactory
        self.errorTranslator = errorTranslator
    }
}

extension InventoryKit
{
    /**
     Client method. Gets the current user’s inventory.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - platform: Publishing platform the user plays on.
        - detailedSubscriptions: Whether detailed subscriptions information is required.
        - completion: Completion with `Result`: Array of `InventoryItem` in case of success and `Error` in case of failure.
     */
    public func getUserInventoryItems(accessToken: String,
                                      projectId: Int,
                                      platform: String?,
                                      detailedSubscriptions: Bool? = false,
                                      completion: @escaping (Result<[InventoryItem], Error>) -> Void)
    {
        api.getUserInventoryItems(accessToken: accessToken, projectId: projectId, platform: platform)
        { [weak self, factory = modelFactory, translator = errorTranslator] result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let items = responseModel.items.map { factory.getInventoryItem(response: $0) }

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

                case .failure(let error): completion(.failure(translator.translateError(error)))
            }
        }
    }

    /**
     Client method. Gets the current user’s virtual balance.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - platform: Publishing platform the user plays on.
        - completion: Completion with `Result`: Array of `InventoryVirtualCurrencyBalance` in case of success and `Error` in case of failure.
     */
    public func getUserVirtualCurrencyBalance(
        accessToken: String,
        projectId: Int,
        platform: String?,
        completion: @escaping (Result<[InventoryVirtualCurrencyBalance], Error>) -> Void)
    {
        api.getUserVirtualCurrencyBalance(accessToken: accessToken, projectId: projectId, platform: platform)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getInventoryVirtualCurrencyBalances(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets the current user’s time-limited items.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - platform: Publishing platform the user plays on.
        - completion: Completion with `Result`: Array of `InventoryUserSubscription` in case of success and `Error` in case of failure.
     */
    public func getTimeLimitedItems(accessToken: String,
                                    projectId: Int,
                                    platform: String?,
                                    completion: @escaping (Result<[TimeLimitedItem], Error>) -> Void)
    {
        api.getTimeLimitedItems(accessToken: accessToken,
                                projectId: projectId,
                                platform: platform)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getTimeLimitedItems(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Client Method. Consumes an item from the current user’s inventory.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - platform: Publishing platform the user plays on.
        - consumingItem: Instance of **InventoryConsumingItem**.
        - completion: Completion with `Result`: success without content or failure with `Error`.
     */
    public func consumeItem(accessToken: String,
                            projectId: Int,
                            platform: String?,
                            consumingItem: InventoryConsumingItem,
                            completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.consumeItem(accessToken: accessToken,
                        projectId: projectId,
                        platform: platform,
                        consumingItem: consumingItem)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
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
                                              completion: @escaping (Result<[InventoryItem], Error>) -> Void)
    {
        getTimeLimitedItems(accessToken: accessToken,
                            projectId: projectId,
                            platform: platform)
        { [translator = errorTranslator] result in

            switch result
            {
                case .success(let subscriptions): do
                {
                    let subscriptions = subscriptions.reduce(into: [:]) { $0[$1.sku] = $1 }
                    let items = inventoryItems.map { $0.withSubscriptionInfo(subscriptions[$0.sku]) }

                    completion(.success(items))
                }

                case .failure(let error): completion(.failure(translator.translateError(error)))
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
