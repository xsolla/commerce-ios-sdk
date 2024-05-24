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

class StoreAPI
{
    let requestPerformer: RequestPerformer
    let responseProcessor: ResponseProcessor
    
    init(requestPerformer: RequestPerformer, responseProcessor: ResponseProcessor)
    {
        logger.debug(.initialization, domain: .storeKit) { String(describing: Self.self) }
        self.requestPerformer = requestPerformer
        self.responseProcessor = responseProcessor
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .storeKit) { deinitingType }
    }
}

extension StoreAPI: StoreAPIProtocol
{
    // MARK: - Virtual items & currency
    
    func getAllVirtualItems(accessToken: String?,
                            projectId: Int,
                            locale: String?,
                            completion: @escaping (StoreAPIResult<GetAllVirtualItemsResponse>) -> Void)
    {
        let params = GetAllVirtualItemsRequest.Params(accessToken: accessToken,
                                                      projectId: projectId,
                                                      locale: locale)
        
        GetAllVirtualItemsRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func getVirtualItems(accessToken: String?,
                         projectId: Int,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetVirtualItemsResponse>) -> Void)
    {
        let params = GetVirtualItemsRequest.Params(accessToken: accessToken,
                                                   projectId: projectId,
                                                   limit: filterParams.limit,
                                                   offset: filterParams.offset,
                                                   locale: filterParams.locale,
                                                   additionalFields: filterParams.additionalFields,
                                                   country: filterParams.country,
                                                   withGeo: filterParams.withGeo)
        
        GetVirtualItemsRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func getVirtualCurrency(projectId: Int,
                            filterParams: StoreFilterParams,
                            completion: @escaping (StoreAPIResult<GetVirtualCurrencyResponse>) -> Void)
    {
        let params = GetVirtualCurrencyRequest.Params(projectId: projectId,
                                                      limit: filterParams.limit,
                                                      offset: filterParams.offset,
                                                      locale: filterParams.locale,
                                                      additionalFields: filterParams.additionalFields,
                                                      country: filterParams.country)
        
        GetVirtualCurrencyRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func getVirtualCurrencyPackages(accessToken: String?,
                                    projectId: Int,
                                    filterParams: StoreFilterParams,
                                    completion: @escaping (StoreAPIResult<GetVirtualCurrencyPackagesResponse>) -> Void)
    {
        let params = GetVirtualCurrencyPackagesRequest.Params(accessToken: accessToken,
                                                              projectId: projectId,
                                                              limit: filterParams.limit,
                                                              offset: filterParams.offset,
                                                              locale: filterParams.locale,
                                                              additionalFields: filterParams.additionalFields,
                                                              country: filterParams.country)
        
        GetVirtualCurrencyPackagesRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    // MARK: - Item groups
    
    func getItemGroups(projectId: Int, completion: @escaping (StoreAPIResult<GetItemGroupsResponse>) -> Void)
    {
        GetItemGroupsRequest(params: .init(projectId: projectId), apiConfiguration: configuration).perform(completion)
    }
    
    func getItemsOfGroup(accessToken: String?,
                         projectId: Int,
                         externalId: String,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetItemsOfGroupResponse>) -> Void)
    {
        let params = GetItemsOfGroupRequest.Params(accessToken: accessToken,
                                                   projectId: projectId,
                                                   externalId: externalId,
                                                   limit: filterParams.limit,
                                                   offset: filterParams.offset,
                                                   locale: filterParams.locale,
                                                   additionalFields: filterParams.additionalFields,
                                                   country: filterParams.country)
        
        GetItemsOfGroupRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    // MARK: - Bundle
    
    func getBundlesList(accessToken: String?,
                        projectId: Int,
                        filterParams: StoreFilterParams,
                        completion: @escaping (StoreAPIResult<GetBundlesListResponse>) -> Void)
    {
        let params = GetBundlesListRequest.Params(accessToken: accessToken,
                                                  projectId: projectId,
                                                  limit: filterParams.limit,
                                                  offset: filterParams.offset,
                                                  locale: filterParams.locale,
                                                  additionalFields: filterParams.additionalFields,
                                                  country: filterParams.country)
        
        GetBundlesListRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func getBundle(accessToken: String?,
                   projectId: Int,
                   sku: String,
                   completion: @escaping (StoreAPIResult<GetBundleResponse>) -> Void)
    {
        GetBundleRequest(params: .init(accessToken: accessToken,
                         projectId: projectId,
                         sku: sku),
                         apiConfiguration: configuration)
            .perform(completion)
    }
    
    // MARK: - Order
    
    func getOrder(projectId: Int,
                  orderId: String,
                  authorizationType: StoreAuthorizationType,
                  completion: @escaping (StoreAPIResult<GetOrderResponse>) -> Void)
    {
        var accessToken: String?
        var unauthorizedId: String?
        var unauthorizedUserEmail: String?
        
        switch authorizationType
        {
            case let .authorized(token):
                accessToken = token

            case let .unauthorized(id, email):
                unauthorizedId = id
                unauthorizedUserEmail = email
        }
        
        let params = GetOrderRequest.Params(projectId: projectId,
                                            orderId: orderId,
                                            accessToken: accessToken,
                                            unauthorizedId: unauthorizedId,
                                            unauthorizedUserEmail: unauthorizedUserEmail)
        
        GetOrderRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
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
    {
        let bodyParams = CreateOrderRequest.Params.BodyParams(currency: currency,
                                                              quantity: quantity,
                                                              locale: locale,
                                                              sandbox: isSandbox,
                                                              settings: paymentProjectSettings,
                                                              customParameters: customParameters)
        
        let params = CreateOrderRequest.Params(projectId: projectId,
                                               accessToken: accessToken,
                                               itemSKU: itemSku,
                                               bodyParams: bodyParams)
        
        CreateOrderRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func createOrderWithCart(accessToken: String,
                             projectId: Int,
                             cartId: String?,
                             currency: String?,
                             locale: String?,
                             isSandbox: Bool,
                             paymentProjectSettings: StorePaymentProjectSettings?,
                             customParameters: [String: String]?,
                             completion: @escaping (StoreAPIResult<CreateOrderResponse>) -> Void)
    {
        if cartId != nil
        {
            let bodyParams = CreateOrderFromParticularCartRequest.BodyParams(currency: currency,
                                                                             locale: locale,
                                                                             sandbox: isSandbox,
                                                                             settings: paymentProjectSettings,
                                                                             customParameters: customParameters)
            
            let params = CreateOrderFromParticularCartRequest.Params(projectId: projectId,
                                                                     cartId: cartId!,
                                                                     accessToken: accessToken,
                                                                     bodyParams: bodyParams)
            
            CreateOrderFromParticularCartRequest(params: params, apiConfiguration: configuration).perform(completion)
        } else
        {
            let bodyParams = CreateOrderFromCurrentCartRequest.BodyParams(currency: currency,
                                                                          locale: locale,
                                                                          sandbox: isSandbox,
                                                                          settings: paymentProjectSettings,
                                                                          customParameters: customParameters)
            
            let params = CreateOrderFromCurrentCartRequest.Params(projectId: projectId,
                                                                  accessToken: accessToken,
                                                                  bodyParams: bodyParams)
            
            CreateOrderFromCurrentCartRequest(params: params, apiConfiguration: configuration).perform(completion)
        }
    }
    
    func createOrderWithFreeCart(accessToken: String,
                                 projectId: Int,
                                 cartId: String?,
                                 completion: @escaping (StoreAPIResult<CreateFreeOrderResponse>) -> Void)
    {
        if cartId != nil
        {
            let params = CreateOrderFromParticularFreeCartRequest.Params(projectId: projectId,
                                                                         cartId: cartId!,
                                                                         accessToken: accessToken)
            
            CreateOrderFromParticularFreeCartRequest(params: params,apiConfiguration: configuration).perform(completion)
        } else
        {
            let params = CreateOrderFromCurrentFreeCartRequest.Params(projectId: projectId,
                                                                      accessToken: accessToken)
            
            CreateOrderFromCurrentFreeCartRequest(params: params, apiConfiguration: configuration).perform(completion)
        }
    }
    
    func createOrderWithFreeItem(accessToken: String,
                                 projectId: Int,
                                 itemSKU: String,
                                 quantity: Int,
                                 completion: @escaping (StoreAPIResult<CreateFreeOrderResponse>) -> Void)
    {
            let bodyParams = CreateOrderWithFreeItemRequest.Params.BodyParams(quantity: quantity)
        
            let params = CreateOrderWithFreeItemRequest.Params(projectId: projectId,
                                                               accessToken: accessToken,
                                                               itemSKU: itemSKU,
                                                               bodyParams: bodyParams)
            
            CreateOrderWithFreeItemRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func purchaseItemByVirtualCurrency(projectId: Int,
                                       accessToken: String,
                                       itemSku: String,
                                       virtualCurrencySku: String,
                                       platform: String?,
                                       customParameters: Encodable?,
                                       completion: @escaping ((StoreAPIResult<PurchaseItemByVirtualCurrencyResponse>) -> Void))
    {
        let params = PurchaseItemByVirtualCurrencyRequest.Params(projectId: projectId,
                                                                 accessToken: accessToken,
                                                                 itemSku: itemSku,
                                                                 virtualCurrencySku: virtualCurrencySku,
                                                                 platform: platform,
                                                                 customParameters: customParameters)
        
        PurchaseItemByVirtualCurrencyRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    // MARK: - Coupons & Promocodes
    
    func redeemCoupon(accessToken: String,
                      projectId: Int,
                      couponCode: String,
                      selectedUnitItems: [String: String]?,
                      completion: @escaping (StoreAPIResult<RedeemCouponResponse>) -> Void)
    {
        let bodyParams = RedeemCouponRequest.Params.BodyParams(couponCode: couponCode,
                                                               selectedUnitItems: selectedUnitItems)
        
        let params = RedeemCouponRequest.Params(accessToken: accessToken,
                                                projectId: projectId,
                                                bodyParams: bodyParams)
        
        RedeemCouponRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func getCouponRewards(accessToken: String,
                          projectId: Int,
                          couponCode: String,
                          completion: @escaping (StoreAPIResult<GetCouponRewardsResponse>) -> Void)
    {
        let params = GetCouponRewardsRequest.Params(accessToken: accessToken,
                                                    projectId: projectId,
                                                    couponCode: couponCode)
        
        GetCouponRewardsRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func redeemPromocode(accessToken: String,
                         projectId: Int,
                         bodyParams: RedeemPromocodeRequest.BodyParams,
                         completion: @escaping (StoreAPIResult<PromocodeResponse>) -> Void)
    {
        let params = RedeemPromocodeRequest.Params(accessToken: accessToken,
                                                   projectId: projectId,
                                                   bodyParams: bodyParams)
        
        RedeemPromocodeRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func removePromocodeFromCart(accessToken: String,
                                 projectId: Int,
                                 bodyParams: RemovePromocodeFromCartRequest.BodyParams,
                                 completion: @escaping (StoreAPIResult<PromocodeResponse>) -> Void)
    {
        let params = RemovePromocodeFromCartRequest.Params(accessToken: accessToken,
                                                           projectId: projectId,
                                                           bodyParams: bodyParams)
        
        RemovePromocodeFromCartRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func getPromocodeRewards(accessToken: String,
                             projectId: Int,
                             promocodeCode: String,
                             completion: @escaping (StoreAPIResult<GetPromocodeRewardsResponse>) -> Void)
    {
        let params = GetPromocodeRewardsRequest.Params(accessToken: accessToken,
                                                       projectId: projectId,
                                                       promocodeCode: promocodeCode)
        
        GetPromocodeRewardsRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    // MARK: - Cart
    
    func getCartByCartId(accessToken: String,
                         projectId: Int,
                         cartId: String,
                         currency: String?,
                         locale: String?,
                         completion: @escaping (StoreAPIResult<GetCartByCartIdResponse>) -> Void)
    {
        let params = GetCartByCartIdRequest.Params(accessToken: accessToken,
                                                   projectId: projectId,
                                                   cartId: cartId,
                                                   currency: currency,
                                                   locale: locale)
        
        GetCartByCartIdRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func getCurrentUserCart(accessToken: String,
                            projectId: Int,
                            currency: String?,
                            locale: String?,
                            completion: @escaping (StoreAPIResult<GetCurrentUserCartResponse>) -> Void)
    {
        let params = GetCurrentUserCartRequest.Params(accessToken: accessToken,
                                                      projectId: projectId,
                                                      currency: currency,
                                                      locale: locale)
        
        GetCurrentUserCartRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func deleteAllCartItemsByCartId(accessToken: String,
                                    projectId: Int,
                                    cartId: String,
                                    completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = DeleteAllCartItemsByCartIdRequest.Params(accessToken: accessToken,
                                                              projectId: projectId,
                                                              cartId: cartId)
        
        DeleteAllCartItemsByCartIdRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func deleteAllCartItemsFromCurrentCart(accessToken: String,
                                           projectId: Int,
                                           completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = DeleteAllCartItemsFromCurrentCartRequest.Params(accessToken: accessToken, projectId: projectId)
        
        DeleteAllCartItemsFromCurrentCartRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func fillCartWithItems(accessToken: String,
                           projectId: Int,
                           items: [FillCartWithItemsRequest.Body.Item],
                           completion: @escaping (StoreAPIResult<FillCartWithItemsResponse>) -> Void)
    {
        let params = FillCartWithItemsRequest.Params(accessToken: accessToken, projectId: projectId, items: items)
        
        FillCartWithItemsRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func fillSpecificCartWithItems(accessToken: String,
                                   projectId: Int,
                                   cartId: String,
                                   items: [FillSpecificCartWithItemsRequest.Body.Item],
                                   completion: @escaping (StoreAPIResult<FillSpecificCartWithItemsResponse>)
                                   -> Void)
    {
        let params = FillSpecificCartWithItemsRequest.Params(accessToken: accessToken,
                                                             projectId: projectId,
                                                             cartId: cartId,
                                                             items: items)
        
        FillSpecificCartWithItemsRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func updateCartItemByCartId(accessToken: String,
                                projectId: Int,
                                cartId: String,
                                itemSKU: String,
                                quantity: Int,
                                completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = UpdateCartItemByCartIdRequest.Params(accessToken: accessToken,
                                                          projectId: projectId,
                                                          cartId: cartId,
                                                          itemSKU: itemSKU,
                                                          quantity: quantity)
        
        UpdateCartItemByCartIdRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func deleteCartItemByCartId(accessToken: String,
                                projectId: Int,
                                cartId: String,
                                itemSKU: String,
                                completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = DeleteCartItemByCartIdRequest.Params(accessToken: accessToken,
                                                          projectId: projectId,
                                                          cartId: cartId,
                                                          itemSKU: itemSKU)
        
        DeleteCartItemByCartIdRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func updateCartItemFromCurrentCart(accessToken: String,
                                       projectId: Int,
                                       itemSKU: String,
                                       quantity: Int,
                                       completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = UpdateCartItemFromCurrentCartRequest.Params(accessToken: accessToken,
                                                                 projectId: projectId,
                                                                 itemSKU: itemSKU,
                                                                 quantity: quantity)
        
        UpdateCartItemFromCurrentCartRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
    
    func deleteCartItemFromCurrentCart(accessToken: String,
                                       projectId: Int,
                                       itemSKU: String,
                                       completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = DeleteCartItemFromCurrentCartRequest.Params(accessToken: accessToken,
                                                                 projectId: projectId,
                                                                 itemSKU: itemSKU)
        
        DeleteCartItemFromCurrentCartRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    // MARK: - Games

    func getGamesList(projectId: Int,
                      limit: Int?,
                      offset: Int?,
                      locale: String?,
                      country: String?,
                      additionalFields: [String]?,
                      completion: @escaping (StoreAPIResult<GetGamesListResponse>) -> Void)
    {
        let params = GetGamesListRequest.Params(projectId: projectId,
                                                limit: limit,
                                                offset: offset,
                                                locale: locale,
                                                country: country,
                                                additionalFields: additionalFields)

        GetGamesListRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    func getGamesListByGroup(projectId: Int,
                             externalId: String,
                             limit: Int?,
                             offset: Int?,
                             locale: String?,
                             country: String?,
                             additionalFields: [String]?,
                             completion: @escaping (StoreAPIResult<GetGamesListResponse>) -> Void)
    {
        let params = GetGamesListByGroupRequest.Params(projectId: projectId,
                                                       externalId: externalId,
                                                       limit: limit,
                                                       offset: offset,
                                                       locale: locale,
                                                       country: country,
                                                       additionalFields: additionalFields)

        GetGamesListByGroupRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    func getGameBySku(projectId: Int,
                      itemSku: String,
                      locale: String?,
                      country: String?,
                      additionalFields: [String]?,
                      completion: @escaping (StoreAPIResult<GameResponse>) -> Void)
    {
        let params = GetGameBySkuRequest.Params(projectId: projectId,
                                                itemSku: itemSku,
                                                locale: locale,
                                                country: country,
                                                additionalFields: additionalFields)

        GetGameBySkuRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    func getGameKeyBySku(projectId: Int,
                         itemSku: String,
                         locale: String?,
                         country: String?,
                         additionalFields: [String]?,
                         completion: @escaping (StoreAPIResult<GameKeyResponse>) -> Void)
    {
        let params = GetGameKeyBySkuRequest.Params(projectId: projectId,
                                                   itemSku: itemSku,
                                                   locale: locale,
                                                   country: country,
                                                   additionalFields: additionalFields)

        GetGameKeyBySkuRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    func getGameKeysByGroup(projectId: Int,
                            externalId: String,
                            limit: Int?,
                            offset: Int?,
                            locale: String?,
                            country: String?,
                            additionalFields: [String]?,
                            completion: @escaping (StoreAPIResult<[GameKeyResponse]>) -> Void)
    {
        let params = GetGameKeysByGroupRequest.Params(projectId: projectId,
                                                      externalId: externalId,
                                                      limit: limit,
                                                      offset: offset,
                                                      locale: locale,
                                                      country: country,
                                                      additionalFields: additionalFields)

        GetGameKeysByGroupRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    func getDRMList(projectId: Int,
                    completion: @escaping (StoreAPIResult<DRMListResponse>) -> Void)
    {
        let params = GetDrmListRequest.Params(projectId: projectId)

        GetDrmListRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    func getUserGamesList(accessToken: String,
                          projectId: Int,
                          limit: Int?,
                          offset: Int?,
                          sandbox: Int?,
                          additionalFields: [String]?,
                          completion: @escaping (StoreAPIResult<UserGamesListResponse>) -> Void)
    {
        let params = GetUserGamesListRequest.Params(accessToken: accessToken,
                                                    projectId: projectId,
                                                    limit: limit,
                                                    offset: offset,
                                                    sandbox: sandbox,
                                                    additionalFields: additionalFields)

        GetUserGamesListRequest(params: params, apiConfiguration: configuration).perform(completion)
    }

    func redeemGameCode(accessToken: String,
                        projectId: Int,
                        code: String,
                        sandbox: Bool?,
                        completion: @escaping (StoreAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = RedeemGameCodeRequest.Params(accessToken: accessToken,
                                                  projectId: projectId,
                                                  bodyParams: .init(code: code, sandbox: sandbox))

        RedeemGameCodeRequest(params: params, apiConfiguration: configuration).perform(completion)
    }
}

extension StoreAPI
{
    var configuration: StoreAPIConfiguration
    {
        StoreAPIConfiguration(requestPerformer: requestPerformer,
                              responseProcessor: responseProcessor,
                              apiBasePath: "https://store.xsolla.com/api")
    }
}
