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
        - projectId: Project ID.
        - completion: List of `StoreItemGroup` in case of success.
     */
    public func getItemGroups(projectId: Int, completion: @escaping StoreKitCompletion<[StoreItemGroup]>)
    {
        api.getItemGroups(projectId: projectId)
        { result in

            if case .success(let response) = result
            {
                let itemGroups = response.groups.map { StoreItemGroup(fromResponse: $0) }
                completion(.success(itemGroups))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets a list of all virtual items for searching on client-side.
     - Parameters:
       - projectId: Project ID.
       - locale: Response language. Two-letter lowercase language code per ISO 639-1.
       - completion: Completion with `Result`: **StoreAllVirtualItems** on success and Error on failure.
     */
    public func getAllVirtualItems(projectId: Int,
                                   locale: String?,
                                   completion: @escaping StoreKitCompletion<[StoreVirtualItemShort]>)
    {
        api.getAllVirtualItems(projectId: projectId, locale: locale)
        { result in

            if case .success(let response) = result
            {
                let virtualItems = response.items.map { StoreVirtualItemShort(fromResponse: $0) }
                completion(.success(virtualItems))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets a virtual items list for building a catalog.
     - Parameters:
        - projectId: Project ID
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreVirtualItem` in case of success.
     */
    public func getVirtualItems(projectId: Int,
                                filterParams: StoreFilterParams,
                                completion: @escaping StoreKitCompletion<[StoreVirtualItem]>)
    {
        api.getVirtualItems(projectId: projectId, filterParams: filterParams)
        { result in

            if case .success(let response) = result
            {
                let virtualItems = response.items.map { StoreVirtualItem(fromResponse: $0) }
                completion(.success(virtualItems))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets a virtual currency list for building a catalog.
     - Parameters:
        - projectId: Project ID.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreVirtualCurrency` in case of success.
     */
    public func getVirtualCurrency(projectId: Int,
                                   filterParams: StoreFilterParams,
                                   completion: @escaping StoreKitCompletion<[StoreVirtualCurrency]>)
    {
        api.getVirtualCurrency(projectId: projectId, filterParams: filterParams)
        { result in

            if case .success(let response) = result
            {
                let virtualCurrencies = response.items.map { StoreVirtualCurrency(fromResponse: $0) }
                completion(.success(virtualCurrencies))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets a virtual currency packages list for building a catalog.
     - Parameters:
        - projectId: Project ID.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of **StoreCurrencyPackage** in case of success.
     */
    public func getVirtualCurrencyPackages(projectId: Int,
                                           filterParams: StoreFilterParams,
                                           completion: @escaping StoreKitCompletion<[StoreCurrencyPackage]>)
    {
        api.getVirtualCurrencyPackages(projectId: projectId, filterParams: filterParams)
        { result in

            if case .success(let response) = result
            {
                let packages = response.items.map { StoreCurrencyPackage(fromResponse: $0) }
                completion(.success(packages))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets an items list from the specified group for building a catalog.
     - Parameters:
        - projectId: Project ID.
        - externalId: Group external ID.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreVirtualItem` in case of success.
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

            if case .success(let response) = result
            {
                let items = response.items.map { StoreVirtualItem(fromResponse: $0) }
                completion(.success(items))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets a list of bundles for building a catalog.
     - Parameters:
        - projectId: Project ID.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreBundle` in case of success.
     */
    public func getBundlesList(projectId: Int,
                               filterParams: StoreFilterParams,
                               completion: @escaping StoreKitCompletion<[StoreBundle]>)
    {
        api.getBundlesList(projectId: projectId, filterParams: filterParams)
        { result in

            if case .success(let response) = result
            {
                let bundleList = response.items.map { StoreBundle(fromResponse: $0) }
                completion(.success(bundleList))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets a specified bundle.
     - Parameters:
        - projectId: Project ID.
        - sku: Bundle SKU.
        - completion: Instance of **StoreBundle** in case of success.
     */
    public func getBundle(projectId: Int,
                          sku: String,
                          completion: @escaping StoreKitCompletion<StoreBundle>)
    {
        api.getBundle(projectId: projectId, sku: sku)
        { result in

            switch result
            {
                case .success(let response): completion(.success(StoreBundle(fromResponse: response)))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Retrieves a specified order.
     - Parameters:
        - projectId: Project ID.
        - orderId: Order ID.
        - authorizationType: Type of authorization in the Store API.
     [See documentation to learn more](https://developers.xsolla.com/doc/buy-button/how-to/set-up-authentication/#guides_buy_button_selling_items_not_authenticated_users).
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
                case .success(let response): completion(.success(StoreOrder(fromResponse: response)))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Creates an order with a specified item. The created order will be given a “new” order status.
     - Parameters:
        - projectId: Project ID.
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can [generate your own token](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui).
        - itemSku: Item SKU.
        - quantity: Item quantity.
        - currency: The currency which prices are displayed in (USD  by default). Three-letter currency code per ISO 4217.
        - locale: Response language.
        - isSandbox: Creates an order in the sandbox mode. The option is available for the company users only.
        - paymentProjectSettings: Payment UI theme. Can be `default` or `defaultDark`.
        - customParameters: Project specific parameters.
        - completion: **Order ID** and **Payment token** in case of success.
     */
    public func createOrder(projectId: Int,
                            accessToken: String,
                            itemSKU: String,
                            quantity: Int = 1,
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
                        quantity: quantity,
                        currency: currency,
                        locale: locale,
                        isSandbox: isSandbox,
                        paymentProjectSettings: paymentProjectSettings,
                        customParameters: customParameters)
        { result in

            if case .success(let response) = result
            {
                let createdOrder = StoreOrderPaymentInfo(orderId: response.orderId,
                                                         paymentToken: response.token,
                                                         isSandbox: isSandbox)
                completion(.success(createdOrder))
            }

            if case .failure(let error) = result { completion(.failure(error)) }
        }
    }

    /**
     Creates item purchase using virtual currency.
     - Parameters:
        - projectId: Project ID.
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can [generate your own token](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui).
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
        - customParameters: Your custom parameters represented as a valid JSON set of key-value pairs.
        - completion: Order ID in case of success.
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
                case .success(let response): completion(.success(response.orderId))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Redeems a coupon code. The user gets a bonus after a coupon is redeemed.
     - Parameters:
        - projectId: Project ID.
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
  You can use the Pay Station Access Token as an alternative.
  You can [generate your own token](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui).
        - couponCode: Unique coupon code. Contains letters and numbers.
        - selectedUnitItems: The reward that is selected by a user. Object key is an SKU of a unit, and a value is an SKU of one of the items in a unit.
        - completion: List of received items.
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

            if case .success(let response) = result
            {
                let bonusItems = response.items.map { StoreCouponRedeemedItem(fromResponse: $0) }
                completion(.success(bonusItems))
            }

            if case .failure(let error) = result { completion(.failure(error.processed)) }
        }
    }

    /**
     Gets coupons rewards by its code. Can be used to let users select one of many items as a bonus.
     The usual case is selecting a DRM if the coupon contains a game as a bonus (type=unit).
     - Parameters:
        - projectId: Project ID.
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can [generate your own token](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui).
        - couponCode: Unique case sensitive code. Contains letters and numbers.
        - completion: Rewards info in case of success.
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
                case .success(let response): completion(.success(StoreCouponRewards(fromResponse: response)))
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
