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


public final class StoreKit
{
    public static let shared = StoreKit()

    private var api: StoreAPIProtocol
    private var modelFactory: ModelFactoryProtocol
    private var errorTranslator: ErrorTranslatorProtocol
    private var ordersTracker: OrdersTracker

    convenience init()
    {
        let requestPerformer = XSDKNetwork(sessionConfiguration: XSDKNetwork.defaultSessionConfiguration)
        let responseProcessor = StoreAPIResponseProcessor()
        let api = StoreAPI(requestPerformer: requestPerformer, responseProcessor: responseProcessor)
        let modelFactory = StoreKitModelFactory()
        let errorTranslator = StoreKitErrorTranslator()

        self.init(api: api, modelFactory: modelFactory, errorTranslator: errorTranslator)
    }

    init(api: StoreAPIProtocol, modelFactory: ModelFactoryProtocol, errorTranslator: ErrorTranslatorProtocol)
    {
        self.api = api
        self.modelFactory = modelFactory
        self.errorTranslator = errorTranslator
        self.ordersTracker = OrdersTracker(storeApi: api)
    }
}

extension StoreKit
{
    /**
     Gets an items groups list for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - completion: List of `StoreItemGroup` in case of success.
     */
    public func getItemGroups(projectId: Int, completion: @escaping (Result<[StoreItemGroup], Error>) -> Void)
    {
        api.getItemGroups(projectId: projectId)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getItemGroups)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets a list of all virtual items for searching on client-side.
     - Parameters:
       - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
       - locale: Response language (English by default). Two-letter lowercase language code per ISO 639-1.
       - completion: Completion with `Result`: **StoreAllVirtualItems** on success and Error on failure.
     */
    public func getAllVirtualItems(accessToken: String? = nil,
                                   projectId: Int,
                                   locale: String? = nil,
                                   completion: @escaping (Result<[StoreVirtualItemShort], Error>) -> Void)
    {
        api.getAllVirtualItems(accessToken: accessToken, projectId: projectId, locale: locale)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getAllVirtualItems)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets a virtual items list for building a catalog.
     - Parameters:
        - projectId: Project ID
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreVirtualItem` in case of success.
     */
    public func getVirtualItems(accessToken: String? = nil,
                                projectId: Int,
                                filterParams: StoreFilterParams,
                                completion: @escaping (Result<[StoreVirtualItem], Error>) -> Void)
    {
        api.getVirtualItems(accessToken: accessToken, projectId: projectId, filterParams: filterParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getVirtualItems)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets a virtual currency list for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreVirtualCurrency` in case of success.
     */
    public func getVirtualCurrency(projectId: Int,
                                   filterParams: StoreFilterParams,
                                   completion: @escaping (Result<[StoreVirtualCurrency], Error>) -> Void)
    {
        api.getVirtualCurrency(projectId: projectId, filterParams: filterParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getVirtualCurrency)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets a virtual currency packages list for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of **StoreCurrencyPackage** in case of success.
     */
    public func getVirtualCurrencyPackages(accessToken: String? = nil,
                                           projectId: Int,
                                           filterParams: StoreFilterParams,
                                           completion: @escaping (Result<[StoreCurrencyPackage], Error>) -> Void)
    {
        api.getVirtualCurrencyPackages(accessToken: accessToken, projectId: projectId, filterParams: filterParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getVirtualCurrencyPackages)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets an items list from the specified group for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - externalId: Group external ID.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreVirtualItem` in case of success.
     */
    public func getItemsOfGroup(accessToken: String? = nil,
                                projectId: Int,
                                externalId: String,
                                filterParams: StoreFilterParams,
                                completion: @escaping (Result<[StoreVirtualItem], Error>) -> Void)
    {
        api.getItemsOfGroup(accessToken: accessToken,
                            projectId: projectId,
                            externalId: externalId,
                            filterParams: filterParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getItemsOfGroup)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets a list of bundles for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - filterParams: Instance of **StoreFilterParams**.
        - completion: List of `StoreBundle` in case of success.
     */
    public func getBundlesList(accessToken: String? = nil,
                               projectId: Int,
                               filterParams: StoreFilterParams,
                               completion: @escaping (Result<[StoreBundle], Error>) -> Void)
    {
        api.getBundlesList(accessToken: accessToken, projectId: projectId, filterParams: filterParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getBundlesList)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets a specified bundle.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - sku: Bundle SKU.
        - completion: Instance of **StoreBundle** in case of success.
     */
    public func getBundle(accessToken: String? = nil,
                          projectId: Int,
                          sku: String,
                          completion: @escaping (Result<StoreBundle, Error>) -> Void)
    {
        api.getBundle(accessToken: accessToken, projectId: projectId, sku: sku)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getBundle)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Retrieves a specified order.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - orderId: Order ID.
        - authorizationType: Type of authorization in the Store API.
     [See documentation to learn more](https://developers.xsolla.com/doc/buy-button/how-to/set-up-authentication/#guides_buy_button_selling_items_not_authenticated_users).
     */
    public func getOrder(projectId: Int,
                         orderId: String,
                         authorizationType: StoreAuthorizationType,
                         completion: @escaping (Result<StoreOrder, Error>) -> Void)
    {
        api.getOrder(projectId: projectId, orderId: orderId, authorizationType: authorizationType)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getOrder)
                .mapError(translator.translateError)
            )
        }
    }
    
    /**
     Establishes connections to an Xsolla server to track the order status. Tracking stops when the status changes to `canceled` or `done`.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - authToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - orderId: Order ID.
        - paymentToken: Payment token.
        - initialized: called after the connection is established. To track the order status correctly, the payment UI should be opened while the connection with the Xsolla server is active (after `initialized` callback).
        - completion: **Status**  in case of success.
     */
    public func trackOrderStatus(projectId: Int,
                               authToken: String,
                               orderId: Int,
                               paymentToken: String,
                               initialized: (() -> Void)? = nil,
                               completion: @escaping (Result<String, Error>) -> Void)
    {
        ordersTracker.addToTracking(projectId: projectId,
                                    authToken: authToken,
                                    orderId: orderId,
                                    paymentToken: paymentToken,
                                    initialized: initialized,
                                    completion: completion)
    }

    /**
     Creates an order with a specified item. The created order will be given a `new` order status.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - itemSku: Item SKU.
        - quantity: Item quantity.
        - currency: The currency which prices are displayed in (USD by default). Three-letter currency code per ISO 4217.
        - locale: Response language (English by default). Two-letter lowercase language code per ISO 639-1.
        - isSandbox: Creates an order in the sandbox mode. The option is available for the company users only.
        - paymentProjectSettings: Payment UI theme. Can be `default` or `defaultDark`.
        - customParameters: Project specific parameters.
        - completion: **Order ID** and **Payment token** in case of success.
     */
    public func createOrder(projectId: Int,
                            accessToken: String,
                            itemSKU: String,
                            quantity: Int = 1,
                            currency: String? = nil,
                            locale: String? = nil,
                            isSandbox: Bool,
                            paymentProjectSettings: StorePaymentProjectSettings? = nil,
                            customParameters: [String: String]? = nil,
                            completion: @escaping (Result<StoreOrderPaymentInfo, Error>) -> Void)
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
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getStoreOrderPaymentInfo(response: $0, isSandbox: isSandbox) }
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Creates an order with all items from the cart. The created order will get a `new` order status.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - cartId: Unique cart identifier.
        - currency: Preferred payment currency (USD by default). Three-letter currency code per ISO 4217.
        - locale: Interface language (English by default). Accepts values according to the ISO 639-1 standard.
        - isSandbox: Whether to open payment UI in the sandbox mode. The option is available for users specified in the list of company users.
        - paymentProjectSettings: Custom Pay Station settings.
        - customParameters: Project specific parameters.
        - completion: Closure with `Result`: `StoreOrderPaymentInfo` in case of success and `Error` in case of failure.
     */
    public func createOrderWithCart(projectId: Int,
                                    accessToken: String,
                                    cartId: String?,
                                    currency: String? = nil,
                                    locale: String? = nil,
                                    isSandbox: Bool,
                                    paymentProjectSettings: StorePaymentProjectSettings? = nil,
                                    customParameters: [String: String]? = nil,
                                    completion: @escaping (Result<StoreOrderPaymentInfo, Error>) -> Void)
    {
        api.createOrderWithCart(accessToken: accessToken,
                                projectId: projectId,
                                cartId: cartId,
                                currency: currency,
                                locale: locale,
                                isSandbox: isSandbox,
                                paymentProjectSettings: paymentProjectSettings,
                                customParameters: customParameters)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getStoreOrderPaymentInfo(response: $0, isSandbox: isSandbox) }
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Create order with free cart.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - cartId: Unique cart identifier.
        - completion: Closure with `Result`: `OrderId` in case of success and `Error` in case of failure.
     */
    public func createOrderWithFreeCart(projectId: Int,
                                        accessToken: String,
                                        cartId: String? = nil,
                                        completion: @escaping (Result<Int, Error>) -> Void)
    {
        api.createOrderWithFreeCart(accessToken: accessToken,
                                    projectId: projectId,
                                    cartId: cartId)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getFreeOrderId)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Create an order with a specified free item.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - itemSku: Item SKU.
        - quantity: Item quantity.
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - completion: Closure with `Result`: `OrderId` in case of success and `Error` in case of failure.
     */
    public func createOrderWithSpecifiedFreeItem(projectId: Int,
                                                 itemSKU: String,
                                                 quantity: Int = 1,
                                                 accessToken: String,
                                                 completion: @escaping (Result<Int, Error>) -> Void)
    {
        api.createOrderWithFreeItem(accessToken: accessToken,
                                    projectId: projectId,
                                    itemSKU: itemSKU,
                                    quantity: quantity)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getFreeOrderId)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Creates item purchase using virtual currency.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
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
                                              platform: String? = nil,
                                              customParameters: Encodable? = nil,
                                              completion: @escaping ((Result<Int, Error>) -> Void))
    {
        api.purchaseItemByVirtualCurrency(projectId: projectId,
                                          accessToken: accessToken,
                                          itemSku: itemSKU,
                                          virtualCurrencySku: virtualCurrencySKU,
                                          platform: platform,
                                          customParameters: customParameters)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getOrderId)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Redeems a coupon code. The user gets a bonus after a coupon is redeemed.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - couponCode: Unique coupon code. Contains letters and numbers.
        - selectedUnitItems: The reward that is selected by a user. Object key is an SKU of a unit, and a value is an SKU of one of the items in a unit.
        - completion: List of received items.
     */
    public func redeemCoupon(projectId: Int,
                             accessToken: String,
                             couponCode: String,
                             selectedUnitItems: [String: String]? = nil,
                             completion: @escaping (Result<[StoreRedeemedCouponItem], Error>) -> Void)
    {
        api.redeemCoupon(accessToken: accessToken,
                         projectId: projectId,
                         couponCode: couponCode,
                         selectedUnitItems: selectedUnitItems)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getRedeemedCouponItems)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Gets coupons rewards by its code. Can be used to let users select one of many items as a bonus.
     The usual case is selecting a DRM if the coupon contains a game as a bonus (type=unit).
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - couponCode: Unique case sensitive code. Contains letters and numbers.**Required**.
        - completion: Rewards info in case of success.
     */
    public func getCouponRewards(projectId: Int,
                                 accessToken: String,
                                 couponCode: String,
                                 completion: @escaping (Result<StoreCouponRewards, Error>) -> Void)
    {
        api.getCouponRewards(accessToken: accessToken,
                             projectId: projectId,
                             couponCode: couponCode)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getCouponRewards)
                .mapError(translator.translateError)
            )
        }
    }

    /**
     Redeems a code of promo code promotion. After redeeming a promo code, the user will get free items and/or the price of the cart and/or particular items will be decreased.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - cartId: Unique cart identifier. **Required**.
        - promocodeCode: Unique code of promo code. Contains letters and numbers. **Required**.
        - completion: Rewards info in case of success. Closure with `Result`: `StorePromocode` in case of success and `Error` in case of failure.
     */
    public func redeemPromoCode(accessToken: String,
                                projectId: Int,
                                cartId: String,
                                promocodeCode: String,
                                selectedUnitItems: [String: String]? = nil,
                                completion: @escaping (Result<StorePromocode, Error>) -> Void)
    {
        let bodyParams = RedeemPromocodeRequest.BodyParams(promocodeCode: promocodeCode,
                                                           cart: .init(id: cartId),
                                                           selectedUnitItems: selectedUnitItems)

        api.redeemPromocode(accessToken: accessToken,
                            projectId: projectId,
                            bodyParams: bodyParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getPromocode)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Removes a promo code from a cart. After the promo code is removed, the total price of all items in the cart will be recalculated without bonuses and discounts provided by a promo code.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - cartId: Unique cart identifier. **Required**.
        - completion: Closure with `Result`: `StorePromocode` in case of success and `Error` in case of failure.
    */
    public func removePromoCodeFromCart(accessToken: String,
                                        projectId: Int,
                                        cartId: String,
                                        completion: @escaping (Result<StorePromocode, Error>) -> Void)
    {
        let bodyParams = RemovePromocodeFromCartRequest.BodyParams(cart: .init(id: cartId))

        api.removePromocodeFromCart(accessToken: accessToken, projectId: projectId, bodyParams: bodyParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getPromocode)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Gets promo code rewards by its code. Can be used to allow users to choose one of many items as a bonus. The usual case is choosing a DRM if the promo code contains a game as a bonus (`type=unit`).
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - promocodeCode: Unique code of promo code. Contains letters and numbers. **Required**.
        - completion: Closure with `Result`: `StorePromocodeRewards` in case of success and `Error` in case of failure.
    */
    public func getPromoCodeRewards(accessToken: String,
                                    projectId: Int,
                                    promocodeCode: String,
                                    completion: @escaping (Result<StorePromocodeRewards, Error>) -> Void)
    {
        api.getPromocodeRewards(accessToken: accessToken, projectId: projectId, promocodeCode: promocodeCode)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getPromocodeRewards)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Returns user’s cart by cart ID.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - cartId: Unique cart identifier. **Required**.
        - currency: Preferred payment currency (USD by default). Three-letter currency code per ISO 4217.
        - locale: Interface language (English by default). Accepts values according to the ISO 639-1 standard.
        - completion: Closure with `Result`: `StoreCart` in case of success and `Error` in case of failure.
    */
    public func getCartByCartId(accessToken: String,
                                projectId: Int,
                                cartId: String,
                                currency: String? = nil,
                                locale: String? = nil,
                                completion: @escaping (Result<StoreCart, Error>) -> Void)
    {
        api.getCartByCartId(accessToken: accessToken,
                            projectId: projectId,
                            cartId: cartId,
                            currency: currency,
                            locale: locale)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreCart)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Returns the current user's cart.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - currency: Preferred payment currency (USD by default). Three-letter currency code per ISO 4217.
        - locale: Interface language (English by default). Accepts values according to the ISO 639-1 standard.
        - completion: Closure with `Result`: `StoreCart` in case of success and `Error` in case of failure.
    */
    public func getCurrentUserCart(accessToken: String,
                                   projectId: Int,
                                   currency: String? = nil,
                                   locale: String? = nil,
                                   completion: @escaping (Result<StoreCart, Error>) -> Void)
    {
        api.getCurrentUserCart(accessToken: accessToken,
                               projectId: projectId,
                               currency: currency,
                               locale: locale)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreCart)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Deletes all cart items.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - cartId: Unique cart identifier. **Required**.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
    */
    public func deleteAllCartItemsByCartId(accessToken: String,
                                           projectId: Int,
                                           cartId: String,
                                           completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.deleteAllCartItemsByCartId(accessToken: accessToken,
                                       projectId: projectId,
                                       cartId: cartId)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Deletes all cart items.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
    */
    public func deleteAllCartItemsFromCurrentCart(accessToken: String,
                                                  projectId: Int,
                                                  completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.deleteAllCartItemsFromCurrentCart(accessToken: accessToken, projectId: projectId)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Fills the cart with items. If the cart already has an item with the same SKU, the existing item will be replaced by the passed value.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - items: List of items.
        - completion: Closure with `Result`: `StoreCartWithWarnings` in case of success and `Error` in case of failure.
    */
    public func fillCartWithItems(accessToken: String,
                                  projectId: Int,
                                  items: [StoreUpdatableCartItem],
                                  completion: @escaping (Result<StoreCartWithWarnings, Error>) -> Void)
    {
        let items = items.map
        {
            FillCartWithItemsRequest.Body.Item(sku: $0.sku, quantity: $0.quantity)
        }

        api.fillCartWithItems(accessToken: accessToken,
                              projectId: projectId,
                              items: items)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreCartWithWarnings)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Fills the specific cart with items. If the cart already has an item with the same SKU, the existing item position will be replaced by the passed value.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - cartId: Unique cart identifier. **Required**.
        - items: List of items.
        - completion: Closure with `Result`: `StoreCartWithWarnings` in case of success and `Error` in case of failure.
    */
    public func fillSpecificCartWithItems(accessToken: String,
                                          projectId: Int,
                                          cartId: String,
                                          items: [StoreUpdatableCartItem],
                                          completion: @escaping (Result<StoreCartWithWarnings, Error>) -> Void)
    {
        let items = items.map
        {
            FillSpecificCartWithItemsRequest.Body.Item(sku: $0.sku, quantity: $0.quantity)
        }

        api.fillSpecificCartWithItems(accessToken: accessToken,
                                      projectId: projectId,
                                      cartId: cartId,
                                      items: items)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreCartWithWarnings)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Updates an existing cart item or creates the one in the specified cart.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - cartId: Unique cart identifier. **Required**.
        - itemSKU: Item SKU. **Required**.
        - quantity: Item quantity. **Required**.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
    */
    public func updateCartItemByCartId(accessToken: String,
                                       projectId: Int,
                                       cartId: String,
                                       itemSKU: String,
                                       quantity: Int,
                                       completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.updateCartItemByCartId(accessToken: accessToken,
                                   projectId: projectId,
                                   cartId: cartId,
                                   itemSKU: itemSKU,
                                   quantity: quantity)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Removes an item from the specified cart.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - cartId: Unique cart identifier. **Required**.
        - itemSKU: Item SKU. **Required**.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
    */
    public func deleteCartItemByCartId(accessToken: String,
                                       projectId: Int,
                                       cartId: String,
                                       itemSKU: String,
                                       completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.deleteCartItemByCartId(accessToken: accessToken,
                                   projectId: projectId,
                                   cartId: cartId,
                                   itemSKU: itemSKU)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Updates an existing cart item or creates the one in the current cart.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - itemSKU: Item SKU. **Required**.
        - quantity: Item quantity. **Required**.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
    */
    public func updateCartItemFromCurrentCart(accessToken: String,
                                              projectId: Int,
                                              itemSKU: String,
                                              quantity: Int,
                                              completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.updateCartItemFromCurrentCart(accessToken: accessToken,
                                          projectId: projectId,
                                          itemSKU: itemSKU,
                                          quantity: quantity)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Removes an item from the current cart.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - itemSKU: Item SKU. **Required**.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
    */
    public func deleteCartItemFromCurrentCart(accessToken: String,
                                              projectId: Int,
                                              itemSKU: String,
                                              completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.deleteCartItemFromCurrentCart(accessToken: accessToken,
                                          projectId: projectId,
                                          itemSKU: itemSKU)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Gets a games list for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - limit: Limit for the number of elements on the page (15 elements are displayed by default).
        - offset: Number of elements from which the list is generated (the count starts from 0).
        - locale: Response language (English by default). Two-letter lowercase language code per ISO 639-1.
        - country: Two-letter uppercase country code per ISO 3166-1 alpha-2. Shows regional prices and restrictions for a catalog if those were specified while creating an item. If you do not specify the country explicitly, it will be set based on user's IP address.
        - additionalFields: The list of additional fields. These fields will be in the response if you send them in your request. Available fields `media_list`, `order', `long_description`.
        - completion: Closure with `Result`: `[StoreGame]` in case of success and `Error` in case of failure.
    */
    public func getGamesList(projectId: Int,
                             limit: Int? = nil,
                             offset: Int? = nil,
                             locale: String? = nil,
                             country: String? = nil,
                             additionalFields: [String]? = nil,
                             completion: @escaping (Result<[StoreGame], Error>) -> Void)
    {
        api.getGamesList(projectId: projectId,
                         limit: limit,
                         offset: offset,
                         locale: locale,
                         country: country,
                         additionalFields: additionalFields)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreGames)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Gets a games list from the specified group for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - externalId: Group external ID. **Required**.
        - limit: Limit for the number of elements on the page (15 elements are displayed by default).
        - offset: Number of elements from which the list is generated (the count starts from 0).
        - locale: Response language (English by default). Two-letter lowercase language code per ISO 639-1.
        - country: Two-letter uppercase country code per ISO 3166-1 alpha-2. Shows regional prices and restrictions for a catalog if those were specified while creating an item. If you do not specify the country explicitly, it will be set based on user's IP address.
        - additionalFields: The list of additional fields. These fields will be in the response if you send them in your request. Available fields `media_list`, `order', `long_description`.
        - completion: Closure with `Result`: `[StoreGame]` in case of success and `Error` in case of failure.
    */
    public func getGamesListByGroup(projectId: Int,
                                    externalId: String,
                                    limit: Int? = nil,
                                    offset: Int? = nil,
                                    locale: String? = nil,
                                    country: String? = nil,
                                    additionalFields: [String]? = nil,
                                    completion: @escaping (Result<[StoreGame], Error>) -> Void)
    {
        api.getGamesListByGroup(projectId: projectId,
                                externalId: externalId,
                                limit: limit,
                                offset: offset,
                                locale: locale,
                                country: country,
                                additionalFields: additionalFields)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreGames)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Gets a game for the catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - item SKU: Item SKU. **Required**.
        - locale: Response language (English by default). Two-letter lowercase language code per ISO 639-1.
        - country: Two-letter uppercase country code per ISO 3166-1 alpha-2. Shows regional prices and restrictions for a catalog if those were specified while creating an item. If you do not specify the country explicitly, it will be set based on user's IP address.
        - additionalFields: The list of additional fields. These fields will be in the response if you send them in your request. Available fields `media_list`, `order', `long_description`.
        - completion: Closure with `Result`: `StoreGame` in case of success and `Error` in case of failure.
    */
    public func getGameBySku(projectId: Int,
                             itemSku: String,
                             locale: String? = nil,
                             country: String? = nil,
                             additionalFields: [String]? = nil,
                             completion: @escaping (Result<StoreGame, Error>) -> Void)
    {
        api.getGameBySku(projectId: projectId,
                         itemSku: itemSku,
                         locale: locale,
                         country: country,
                         additionalFields: additionalFields)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreGame)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Gets a game key for the catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - item SKU: Item SKU. **Required**.
        - locale: Response language (English by default). Two-letter lowercase language code per ISO 639-1.
        - country: Two-letter uppercase country code per ISO 3166-1 alpha-2. Shows regional prices and restrictions for a catalog if those were specified while creating an item. If you do not specify the country explicitly, it will be set based on user's IP address.
        - additionalFields: The list of additional fields. These fields will be in the response if you send them in your request. Available fields `media_list`, `order', `long_description`.
        - completion: Closure with `Result`: `StoreGame` in case of success and `Error` in case of failure.
    */
    public func getGameKeyBySku(projectId: Int,
                                itemSku: String,
                                locale: String? = nil,
                                country: String? = nil,
                                additionalFields: [String]? = nil,
                                completion: @escaping (Result<StoreGameKey, Error>) -> Void)
    {
        api.getGameKeyBySku(projectId: projectId,
                            itemSku: itemSku,
                            locale: locale,
                            country: country,
                            additionalFields: additionalFields)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreGameKey)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Gets a game key list from the specified group for building a catalog.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - externalId: Group external ID. **Required**.
        - limit: Limit for the number of elements on the page (15 elements are displayed by default).
        - offset: Number of elements from which the list is generated (the count starts from 0).
        - locale: Response language (English by default). Two-letter lowercase language code per ISO 639-1.
        - country: Two-letter uppercase country code per ISO 3166-1 alpha-2. Shows regional prices and restrictions for a catalog if those were specified while creating an item. If you do not specify the country explicitly, it will be set based on user's IP address.
        - additionalFields: The list of additional fields. These fields will be in the response if you send them in your request. Available fields `media_list`, `order', `long_description`.
        - completion: Closure with `Result`: `[StoreGameKey]` in case of success and `Error` in case of failure.
    */
    public func getGameKeysByGroup(projectId: Int,
                                   externalId: String,
                                   limit: Int? = nil,
                                   offset: Int? = nil,
                                   locale: String? = nil,
                                   country: String? = nil,
                                   additionalFields: [String]? = nil,
                                   completion: @escaping (Result<[StoreGameKey], Error>) -> Void)
    {
        api.getGameKeysByGroup(projectId: projectId,
                               externalId: externalId,
                               limit: limit,
                               offset: offset,
                               locale: locale,
                               country: country,
                               additionalFields: additionalFields)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreGameKeys)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Gets the list of available DRMs.
     - Parameters:
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - completion: Closure with `Result`: `[StoreDRM]` in case of success and `Error` in case of failure.
    */
    public func getDRMList(projectId: Int,
                           completion: @escaping (Result<[StoreDRM], Error>) -> Void)
    {
        api.getDRMList(projectId: projectId)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreDRMs)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Get the list of games owned by the user. The response will contain an array of games owned by a particular user..
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - limit: Limit for the number of elements on the page (15 elements are displayed by default).
        - offset: Number of elements from which the list is generated (the count starts from 0).
        - sandbox: What type of entitlements should be returned. If the parameter is set to 1, the entitlements received by the user in the sandbox mode only are returned. If the parameter isn't passed or is set to 0, the entitlements received by the user in the live mode only are returned.
        - additionalFields: The list of additional fields. These fields will be in the response if you send them in your request. Available fields `attributes`.
        - completion: Closure with `Result`: `StoreUserGamesList` in case of success and `Error` in case of failure.
    */
    public func getUserGamesList(accessToken: String,
                                 projectId: Int,
                                 limit: Int? = nil,
                                 offset: Int? = nil,
                                 sandbox: Int? = nil,
                                 additionalFields: [String]? = nil,
                                 completion: @escaping (Result<StoreUserGamesList, Error>) -> Void)
    {
        api.getUserGamesList(accessToken: accessToken,
                             projectId: projectId,
                             limit: limit,
                             offset: offset,
                             sandbox: sandbox,
                             additionalFields: additionalFields)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map(factory.getStoreUserGamesList)
                .mapError(translator.translateError)
            )
        }
    }

    /**
    Grants entitlement by a provided game code. You can redeem codes only for the DRM-free platform.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - projectId: Project ID, can be found in Publisher Account next to the name of the project. **Required**.
        - code: Game code. **Required**.
        - sandbox: Whether to redeem game code in the sandbox mode (`false` by default). The option is available for those users who are specified in the list of company users.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
    */
    public func redeemGameCode(accessToken: String,
                               projectId: Int,
                               code: String,
                               sandbox: Bool? = nil,
                               completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.redeemGameCode(accessToken: accessToken,
                           projectId: projectId,
                           code: code,
                           sandbox: sandbox)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError(translator.translateError)
            )
        }
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
