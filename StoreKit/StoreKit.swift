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

// swiftlint:disable function_parameter_count

import Foundation
import XsollaSDKUtilities

public typealias StoreKitResult<T> = Result<T, Error>
public typealias StoreKitCompletion<T> = (StoreKitResult<T>) -> Void

public final class StoreKit
{
    public static let shared = StoreKit()

    private var api: StoreAPIProtocol

    convenience init()
    {
        let requestPerformer = XSDKNetwork(sessionConfiguration: XSDKNetwork.defaultSessionConfiguration)
        let responseProcessor = StoreAPIResponseProcessor()
        let api = StoreAPI(requestPerformer: requestPerformer, responseProcessor: responseProcessor)

        self.init(api: api)
    }

    init(api: StoreAPIProtocol)
    {
        self.api = api
    }
}

extension StoreKit
{
    /**
     Gets an items groups list for building a catalog.
     - Parameters:
        - projectId: Project ID
        - completion: List of `StoreItemGroup` on success.
     */
    public func getItemGroups(projectId: Int, completion: @escaping StoreKitCompletion<[StoreItemGroup]>)
    {
        api.getItemGroups(projectId: projectId)
        { result in

            switch result
            {
                case .success(let responseModel): do
                {
                    let itemGroups = responseModel.groups.map { StoreItemGroup(fromAPIResponse: $0) }
                    completion(.success(itemGroups))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a virtual items list for building a catalog.
     - Parameters:
        - projectId: Project ID
        - filterParams: Instance of `StoreFilterParams`
        - completion: List of `StoreVirtualItem` on success.
     */
    public func getVirtualItems(projectId: Int,
                                filterParams: StoreFilterParams,
                                completion: @escaping StoreKitCompletion<[StoreVirtualItem]>)
    {
        api.getVirtualItems(projectId: projectId, filterParams: filterParams)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let virtualItems = responseModel.items.map { StoreVirtualItem(fromGetVirtualItemsResponse: $0) }
                    completion(.success(virtualItems))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a virtual currency list for building a catalog.
     - Parameters:
        - projectId: Project ID
        - filterParams: Instance of `StoreFilterParams`
        - completion: List of `StoreVirtualCurrency` on completion.
     */
    public func getVirtualCurrency(projectId: Int,
                                   filterParams: StoreFilterParams,
                                   completion: @escaping StoreKitCompletion<[StoreVirtualCurrency]>)
    {
        api.getVirtualCurrency(projectId: projectId, filterParams: filterParams)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let virtualCurrencies = responseModel.items.map { StoreVirtualCurrency(fromAPIResponse: $0) }
                    completion(.success(virtualCurrencies))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a virtual currency packages list for building a catalog.
     - Parameters:
        - projectId: Project ID
        - filterParams: Instance of `StoreFilterParams`
        - completion: List of `StoreCurrencyPackage` on completion.
     */
    public func getVirtualCurrencyPackages(projectId: Int,
                                           filterParams: StoreFilterParams,
                                           completion: @escaping StoreKitCompletion<[StoreCurrencyPackage]>)
    {
        api.getVirtualCurrencyPackages(projectId: projectId, filterParams: filterParams)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let packages = responseModel.items.map { StoreCurrencyPackage(fromAPIResponse: $0) }
                    completion(.success(packages))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets an items list from the specified group for building a catalog.
     - Parameters:
        - projectId: Project ID
        - externalId: Group external ID.
        - filterParams: Instance of `StoreFilterParams`
        - completion: List of `StoreVirtualItem` on completion.
     */
    public func getItemsOfGroup(projectId: Int,
                                externalId: String,
                                filterParams: StoreFilterParams,
                                completion: @escaping StoreKitCompletion<[StoreVirtualItem]>)
    {
        api.getItemsOfGroup(projectId: projectId,
                            externalId: externalId,
                            filterParams: filterParams)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let items = responseModel.items.map { StoreVirtualItem(fromGetItemsOfGroupResponse: $0) }
                    completion(.success(items))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a list of bundles for building a catalog.
     - Parameters:
        - projectId: Project ID
        - filterParams: Instance of `StoreFilterParams`
        - completion: List of `StoreBundle` on completion.
     */
    public func getBundlesList(projectId: Int,
                               filterParams: StoreFilterParams,
                               completion: @escaping StoreKitCompletion<[StoreBundle]>)
    {
        api.getBundlesList(projectId: projectId, filterParams: filterParams)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let bundleList = responseModel.items.map { StoreBundle(fromGetBundleListResponse: $0) }
                    completion(.success(bundleList))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a specified bundle.
     - Parameters:
        - projectId: Project ID
        - sku: Bundle SKU.
        - completion: Instance of `StoreBundle` on completion.
     */
    public func getBundle(projectId: Int,
                          sku: String,
                          completion: @escaping StoreKitCompletion<StoreBundle>)
    {
        api.getBundle(projectId: projectId, sku: sku)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let bundle = StoreBundle(fromGetBundleResponse: responseModel)
                    completion(.success(bundle))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Retrieves a specified order.
     - Parameters:
        - projectId: Project ID
        - orderId: Order ID.
        - authorizationType: Type of authorization in Store API.
     More info [here](https://developers.xsolla.com/doc/buy-button/how-to/set-up-authentication/#guides_buy_button_selling_items_not_authenticated_users).
     */
    public func getOrder(projectId: Int,
                         orderId: String,
                         authorizationType: StoreAuthorizationType,
                         completion: @escaping StoreKitCompletion<StoreOrder>)
    {
        api.getOrder(projectId: projectId, orderId: orderId, authorizationType: authorizationType)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let order = StoreOrder(fromGetOrderResponse: responseModel)
                    completion(.success(order))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Creates an order with a specified item. The created order will be given a “new” order status.
     - Parameters:
        - projectId: Project ID
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui))
        - itemSku: Item SKU
        - currency: The currency which prices are displayed in (USD  by default). Three-letter currency code per ISO 4217.
        - locale: Response language.
        - isSandbox: Creates an order in the sandbox mode. The option is available for the company users only.
        - paymentProjectSettings: Payment UI theme. Can be `default` or `defaultDark`.
        - customParameters: Project specific parameters.
        - completion: **Order ID** and **Payment token** on success
     */
    public func createOrder(projectId: Int,
                            accessToken: String,
                            itemSKU: String,
                            currency: String?,
                            locale: String?,
                            isSandbox: Bool,
                            paymentProjectSettings: StorePaymentProjectSettings? = nil,
                            customParameters: [String: String]? = nil,
                            completion: @escaping StoreKitCompletion<StoreOrderPaymentInfo>)
    {
        api.createOrder(accessToken: accessToken,
                        projectId: projectId,
                        itemSku: itemSKU,
                        currency: currency,
                        locale: locale,
                        isSandbox: isSandbox,
                        paymentProjectSettings: paymentProjectSettings,
                        customParameters: customParameters)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let createdOrder = StoreOrderPaymentInfo(orderId: responseModel.orderId,
                                                             paymentToken: responseModel.token,
                                                             isSandbox: isSandbox)
                    completion(.success(createdOrder))
                }

                case .failure(let error): completion(.failure(error))
            }
        }
    }

    /**
     Creates item purchase using virtual currency.
     - Parameters:
        - projectId: Project ID
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui))
        - itemSKU: Item SKU.
        - virtualCurrencySKU: Virtual currency SKU. Can be:
            * `playstation_network`
            * `xbox_live`
            * `xsolla`
            * `pc_standalone`
            * `nintendo_shop`
            * `google_play`
            * `app_store_ios`
            * `android_standalone`
            * `ios_standalone`
            * `android_other`
            * `ios_other`
            * `pc_other`
        - platform: Publishing platform the user plays on.
        - customParameters: Your custom parameters, represented as a valid JSON set of key-value pairs.
        - completion: Order ID on success.
     */
    public func purchaseItemByVirtualCurrency(projectId: Int,
                                              accessToken: String,
                                              itemSKU: String,
                                              virtualCurrencySKU: String,
                                              platform: String?,
                                              customParameters: Encodable?,
                                              completion: @escaping (StoreKitCompletion<Int>))
    {
        api.purchaseItemByVirtualCurrency(projectId: projectId,
                                          accessToken: accessToken,
                                          itemSku: itemSKU,
                                          virtualCurrencySku: virtualCurrencySKU,
                                          platform: platform,
                                          customParameters: customParameters)
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel.orderId))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Redeems a coupon code. The user gets a bonus after a coupon is redeemed.
     - Parameters:
        - projectId: Project ID
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
  You can use the Pay Station Access Token as an alternative.
  You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui))
        - couponCode: Unique coupon code. Contains letters and numbers.
        - selectedUnitItems: The reward that is selected by a user. Object key is an SKU of a unit, and value is an SKU of one of the items in a unit.
        - completion: List of recieved items.
     */
    public func redeemCoupon(projectId: Int,
                             accessToken: String,
                             couponCode: String,
                             selectedUnitItems: [String: String]?,
                             completion: @escaping StoreKitCompletion<[StoreCouponRedeemedItem]>)
    {
        api.redeemCoupon(accessToken: accessToken,
                         projectId: projectId,
                         couponCode: couponCode,
                         selectedUnitItems: selectedUnitItems)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let bonusItems = responseModel.items.map { StoreCouponRedeemedItem(fromRedeemCouponResponse: $0) }
                    completion(.success(bonusItems))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets coupons rewards by its code. Can be used to allow users to choose one of many items as a bonus.
     The usual case is choosing a DRM if the coupon contains a game as a bonus (type=unit).
     - Parameters:
        - projectId: Project ID
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui))
        - couponCode: Unique case sensitive code. Contains letters and numbers.
        - completion: Rewards info on success.
     */
    public func getCouponRewards(projectId: Int,
                                 accessToken: String,
                                 couponCode: String,
                                 completion: @escaping StoreKitCompletion<StoreCouponRewards>)
    {
        api.getCouponRewards(accessToken: accessToken,
                             projectId: projectId,
                             couponCode: couponCode)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let rewards = StoreCouponRewards(fromGetCouponRewardsResponse: responseModel)
                    completion(.success(rewards))
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
        if case .parameters(_, let model) = self as? APIError<StoreAPIErrorModel>
        {
            return StoreKitError(code: model?.code) ?? self
        }

        return self
    }
}

public enum StoreKitError: Error
{
    case notEnoughVirtualCurrency

    internal init?(code: Int?)
    {
        switch code
        {
            case 5006: self = .notEnoughVirtualCurrency

            default: return nil
        }
    }
}
