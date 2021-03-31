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
    func getItemGroups(projectId: Int, completion: @escaping (StoreAPIResult<GetItemGroupsResponse>) -> Void)
    {
        GetItemGroupsAPIProxy(configuration).getItemGroups(projectId: projectId, completion: completion)
    }
    
    func getVirtualItems(projectId: Int,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetVirtualItemsResponse>) -> Void)
    {
        GetVirtualItemsAPIProxy(configuration).getVirtualItems(projectId: projectId,
                                                               filterParams: filterParams,
                                                               completion: completion)
    }
    
    func getVirtualCurrency(projectId: Int,
                            filterParams: StoreFilterParams,
                            completion: @escaping (StoreAPIResult<GetVirtualCurrencyResponse>) -> Void)
    {
        GetVirtualCurrencyAPIProxy(configuration).getVirtualCurrency(projectId: projectId,
                                                                     filterParams: filterParams,
                                                                     completion: completion)
    }
    
    func getVirtualCurrencyPackages(projectId: Int,
                                    filterParams: StoreFilterParams,
                                    completion: @escaping (StoreAPIResult<GetVirtualCurrencyPackagesResponse>) -> Void)
    {
        GetVirtualCurrencyPackagesAPIProxy(configuration).getVirtualCurrencyPackages(projectId: projectId,
                                                                                     filterParams: filterParams,
                                                                                     completion: completion)
    }
    
    func getItemsOfGroup(projectId: Int,
                         externalId: String,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetItemsOfGroupResponse>) -> Void)
    {
        GetItemsOfGroupAPIProxy(configuration).getItemsOfGroup(projectId: projectId,
                                                               externalId: externalId,
                                                               filterParams: filterParams,
                                                               completion: completion)
    }
    
    func getBundlesList(projectId: Int,
                        filterParams: StoreFilterParams,
                        completion: @escaping (StoreAPIResult<GetBundlesListResponse>) -> Void)
    {
        GetBundlesListAPIProxy(configuration).getBundlesList(projectId: projectId,
                                                           filterParams: filterParams,
                                                           completion: completion)
    }
    
    func getBundle(projectId: Int, sku: String, completion: @escaping (StoreAPIResult<GetBundleResponse>) -> Void)
    {
        GetBundleAPIProxy(configuration).getBundle(projectId: projectId, sku: sku, completion: completion)
    }
    
    func getOrder(projectId: Int,
                  orderId: String,
                  authorizationType: StoreAuthorizationType,
                  completion: @escaping (StoreAPIResult<GetOrderResponse>) -> Void)
    {
        GetOrderAPIProxy(configuration).getOrder(projectId: projectId,
                                                 orderId: orderId,
                                                 authorizationType: authorizationType,
                                                 completion: completion)
    }
    
    func createOrder(accessToken: String,
                     projectId: Int,
                     itemSku: String,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     paymentProjectSettings: StorePaymentProjectSettings?,
                     customParameters: [String: String]?,
                     completion: @escaping (StoreAPIResult<CreateOrderResponse>) -> Void)
    {
        CreateOrderAPIProxy(configuration).createOrder(accessToken: accessToken,
                                                       projectId: projectId,
                                                       itemSku: itemSku,
                                                       currency: currency,
                                                       locale: locale,
                                                       isSandbox: isSandbox,
                                                       paymentProjectSettings: paymentProjectSettings,
                                                       customParameters: customParameters,
                                                       completion: completion)
    }
    
    func purchaseItemByVirtualCurrency(
        projectId: Int,
        accessToken: String,
        itemSku: String,
        virtualCurrencySku: String,
        platform: String?,
        customParameters: Encodable?,
        completion: @escaping ((StoreAPIResult<PurchaseItemByVirtualCurrencyResponse>) -> Void))
    {
        let proxy = PurchaseItemByVirtualCurrencyAPIProxy(configuration)
        proxy.purchaseItemByVirtualCurrency(projectId: projectId,
                                            accessToken: accessToken,
                                            itemSku: itemSku,
                                            virtualCurrencySku: virtualCurrencySku,
                                            platform: platform,
                                            customParameters: customParameters,
                                            completion: completion)
    }
    
    func redeemCoupon(accessToken: String,
                      projectId: Int,
                      couponCode: String,
                      selectedUnitItems: [String: String]?,
                      completion: @escaping (StoreAPIResult<RedeemCouponResponse>) -> Void)
    {
        RedeemCouponAPIProxy(configuration).redeemCoupon(accessToken: accessToken,
                                                         projectId: projectId,
                                                         couponCode: couponCode,
                                                         selectedUnitItems: selectedUnitItems,
                                                         completion: completion)
    }
    
    func getCouponRewards(accessToken: String,
                          projectId: Int,
                          couponCode: String,
                          completion: @escaping (StoreAPIResult<GetCouponRewardsResponse>) -> Void)
    {
        GetCouponRewardsAPIProxy(configuration).getCouponRewards(accessToken: accessToken,
                                                                 projectId: projectId,
                                                                 couponCode: couponCode,
                                                                 completion: completion)
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
