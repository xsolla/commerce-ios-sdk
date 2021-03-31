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
    func getItemGroups(projectId: Int, completion: @escaping (StoreAPIResult<GetItemGroupsResponse>) -> Void)
    
    func getVirtualItems(projectId: Int,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetVirtualItemsResponse>) -> Void)
    
    func getVirtualCurrency(projectId: Int,
                            filterParams: StoreFilterParams,
                            completion: @escaping (StoreAPIResult<GetVirtualCurrencyResponse>) -> Void)
    
    func getVirtualCurrencyPackages(projectId: Int,
                                    filterParams: StoreFilterParams,
                                    completion: @escaping (StoreAPIResult<GetVirtualCurrencyPackagesResponse>) -> Void)
    
    func getItemsOfGroup(projectId: Int,
                         externalId: String,
                         filterParams: StoreFilterParams,
                         completion: @escaping (StoreAPIResult<GetItemsOfGroupResponse>) -> Void)
    
    func getBundlesList(projectId: Int,
                        filterParams: StoreFilterParams,
                        completion: @escaping (StoreAPIResult<GetBundlesListResponse>) -> Void)
    
    func getBundle(projectId: Int, sku: String, completion: @escaping (StoreAPIResult<GetBundleResponse>) -> Void)
    
    func getOrder(projectId: Int,
                  orderId: String,
                  authorizationType: StoreAuthorizationType,
                  completion: @escaping (StoreAPIResult<GetOrderResponse>) -> Void)
    
    func createOrder(accessToken: String,
                     projectId: Int,
                     itemSku: String,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     paymentProjectSettings: StorePaymentProjectSettings?,
                     customParameters: [String: String]?,
                     completion: @escaping (StoreAPIResult<CreateOrderResponse>) -> Void)
    
    func purchaseItemByVirtualCurrency(
        projectId: Int,
        accessToken: String,
        itemSku: String,
        virtualCurrencySku: String,
        platform: String?,
        customParameters: Encodable?,
        completion: @escaping ((StoreAPIResult<PurchaseItemByVirtualCurrencyResponse>) -> Void))
    
    func redeemCoupon(accessToken: String,
                      projectId: Int,
                      couponCode: String,
                      selectedUnitItems: [String: String]?,
                      completion: @escaping (StoreAPIResult<RedeemCouponResponse>) -> Void)
    
    func getCouponRewards(accessToken: String,
                          projectId: Int,
                          couponCode: String,
                          completion: @escaping (StoreAPIResult<GetCouponRewardsResponse>) -> Void)
}
