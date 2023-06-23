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

typealias StoreAPIError = Error
typealias StoreAPIResult<T> = Result<T, StoreAPIError>

protocol StoreAPIProtocol
{
    // MARK: - Virtual items & currency
    
    func getAllVirtualItems(accessToken: String?,
                            projectId: Int,
                            locale: String?,
                            completion: @escaping (StoreAPIResult<GetAllVirtualItemsResponse>) -> Void)
    
    func getVirtualItems(accessToken: String?,
                         projectId: Int,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetVirtualItemsResponse>) -> Void)
    
    func getVirtualCurrency(projectId: Int,
                            filterParams: StoreFilterParams,
                            completion: @escaping (StoreAPIResult<GetVirtualCurrencyResponse>) -> Void)
    
    func getVirtualCurrencyPackages(accessToken: String?,
                                    projectId: Int,
                                    filterParams: StoreFilterParams,
                                    completion: @escaping (StoreAPIResult<GetVirtualCurrencyPackagesResponse>) -> Void)
    
    // MARK: - Item groups
    
    func getItemGroups(projectId: Int, completion: @escaping (StoreAPIResult<GetItemGroupsResponse>) -> Void)
    
    func getItemsOfGroup(accessToken: String?,
                         projectId: Int,
                         externalId: String,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetItemsOfGroupResponse>) -> Void)
    
    // MARK: - Bundle
    
    func getBundlesList(accessToken: String?,
                        projectId: Int,
                        filterParams: StoreFilterParams,
                        completion: @escaping (StoreAPIResult<GetBundlesListResponse>) -> Void)
    
    func getBundle(accessToken: String?,
                   projectId: Int,
                   sku: String,
                   completion: @escaping (StoreAPIResult<GetBundleResponse>) -> Void)
    
    // MARK: - Order
    
    func getOrder(projectId: Int,
                  orderId: String,
                  authorizationType: StoreAuthorizationType,
                  completion: @escaping (StoreAPIResult<GetOrderResponse>) -> Void)
    
    func createOrder(accessToken: String,
                     projectId: Int,
                     itemSku: String,
                     quantity: Int,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     paymentProjectSettings: StorePaymentProjectSettings?,
                     customParameters: [String: String]?,
                     completion: @escaping (StoreAPIResult<CreateOrderResponse>) -> Void)
    
    func createOrderWithCart(accessToken: String,
                             projectId: Int,
                             cartId: String?,
                             currency: String?,
                             locale: String?,
                             isSandbox: Bool,
                             paymentProjectSettings: StorePaymentProjectSettings?,
                             customParameters: [String: String]?,
                             completion: @escaping (StoreAPIResult<CreateOrderResponse>) -> Void)
    
    func createOrderWithFreeCart(accessToken: String,
                                 projectId: Int,
                                 cartId: String?,
                                 completion: @escaping (StoreAPIResult<CreateFreeOrderResponse>) -> Void)
    
    func createOrderWithFreeItem(accessToken: String,
                                 projectId: Int,
                                 itemSKU: String,
                                 quantity: Int,
                                 completion: @escaping (StoreAPIResult<CreateFreeOrderResponse>) -> Void)
    
    func purchaseItemByVirtualCurrency(
        projectId: Int,
        accessToken: String,
        itemSku: String,
        virtualCurrencySku: String,
        platform: String?,
        customParameters: Encodable?,
        completion: @escaping ((StoreAPIResult<PurchaseItemByVirtualCurrencyResponse>) -> Void))
    
    // MARK: - Coupons & Promocodes
    
    func redeemCoupon(accessToken: String,
                      projectId: Int,
                      couponCode: String,
                      selectedUnitItems: [String: String]?,
                      completion: @escaping (StoreAPIResult<RedeemCouponResponse>) -> Void)
    
    func getCouponRewards(accessToken: String,
                          projectId: Int,
                          couponCode: String,
                          completion: @escaping (StoreAPIResult<GetCouponRewardsResponse>) -> Void)
    
    func redeemPromocode(accessToken: String,
                         projectId: Int,
                         bodyParams: RedeemPromocodeRequest.BodyParams,
                         completion: @escaping (StoreAPIResult<PromocodeResponse>) -> Void)
    
    func removePromocodeFromCart(accessToken: String,
                                 projectId: Int,
                                 bodyParams: RemovePromocodeFromCartRequest.BodyParams,
                                 completion: @escaping (StoreAPIResult<PromocodeResponse>) -> Void)
    
    func getPromocodeRewards(accessToken: String,
                             projectId: Int,
                             promocodeCode: String,
                             completion: @escaping (StoreAPIResult<GetPromocodeRewardsResponse>) -> Void)
    
    // MARK: - Cart
    
    func getCartByCartId(accessToken: String,
                         projectId: Int,
                         cartId: String,
                         currency: String?,
                         locale: String?,
                         completion: @escaping (StoreAPIResult<GetCartByCartIdResponse>) -> Void)
    
    func getCurrentUserCart(accessToken: String,
                            projectId: Int,
                            currency: String?,
                            locale: String?,
                            completion: @escaping (StoreAPIResult<GetCurrentUserCartResponse>) -> Void)
    
    func deleteAllCartItemsByCartId(accessToken: String,
                                    projectId: Int,
                                    cartId: String,
                                    completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    
    func deleteAllCartItemsFromCurrentCart(accessToken: String,
                                           projectId: Int,
                                           completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    
    func fillCartWithItems(accessToken: String,
                           projectId: Int,
                           items: [FillCartWithItemsRequest.Body.Item],
                           completion: @escaping (StoreAPIResult<FillCartWithItemsResponse>) -> Void)
    
    func fillSpecificCartWithItems(accessToken: String,
                                   projectId: Int,
                                   cartId: String,
                                   items: [FillSpecificCartWithItemsRequest.Body.Item],
                                   completion: @escaping (StoreAPIResult<FillSpecificCartWithItemsResponse>) -> Void)
    
    func updateCartItemByCartId(accessToken: String,
                                projectId: Int,
                                cartId: String,
                                itemSKU: String,
                                quantity: Int,
                                completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    
    func deleteCartItemByCartId(accessToken: String,
                                projectId: Int,
                                cartId: String,
                                itemSKU: String,
                                completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    
    func updateCartItemFromCurrentCart(accessToken: String,
                                       projectId: Int,
                                       itemSKU: String,
                                       quantity: Int,
                                       completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    
    func deleteCartItemFromCurrentCart(accessToken: String,
                                       projectId: Int,
                                       itemSKU: String,
                                       completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    
    // MARK: - Games
    
    func getGamesList(projectId: Int,
                      limit: Int?,
                      offset: Int?,
                      locale: String?,
                      country: String?,
                      additionalFields: [String]?,
                      completion: @escaping (StoreAPIResult<GetGamesListResponse>) -> Void)

    func getGamesListByGroup(projectId: Int,
                             externalId: String,
                             limit: Int?,
                             offset: Int?,
                             locale: String?,
                             country: String?,
                             additionalFields: [String]?,
                             completion: @escaping (StoreAPIResult<GetGamesListResponse>) -> Void)

    func getGameBySku(projectId: Int,
                      itemSku: String,
                      locale: String?,
                      country: String?,
                      additionalFields: [String]?,
                      completion: @escaping (StoreAPIResult<GameResponse>) -> Void)

    func getGameKeyBySku(projectId: Int,
                         itemSku: String,
                         locale: String?,
                         country: String?,
                         additionalFields: [String]?,
                         completion: @escaping (StoreAPIResult<GameKeyResponse>) -> Void)

    func getGameKeysByGroup(projectId: Int,
                            externalId: String,
                            limit: Int?,
                            offset: Int?,
                            locale: String?,
                            country: String?,
                            additionalFields: [String]?,
                            completion: @escaping (StoreAPIResult<[GameKeyResponse]>) -> Void)

    func getDRMList(projectId: Int,
                    completion: @escaping (StoreAPIResult<DRMListResponse>) -> Void)

    func getUserGamesList(accessToken: String,
                          projectId: Int,
                          limit: Int?,
                          offset: Int?,
                          sandbox: Int?,
                          additionalFields: [String]?,
                          completion: @escaping (StoreAPIResult<UserGamesListResponse>) -> Void)

    func redeemGameCode(accessToken: String,
                        projectId: Int,
                        code: String,
                        sandbox: Bool?,
                        completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
}
