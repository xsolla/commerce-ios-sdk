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

// swiftlint:disable opening_braces
// swiftlint:disable closure_end_indentation
// swiftlint:disable function_parameter_count

import Foundation
import XsollaSDKInventoryKit
import XsollaSDKLoginKit
import XsollaSDKStoreKit

final class XsollaSDK
{
    let loginManager: LoginManagerProtocol
    
    private(set) var currentUserInfo: AppUserInfo?
    
    private var login: LoginKit { .shared }
    private var inventory: InventoryKit { .shared }
    private var store: StoreKit { .shared }
    
    @Atomic private var isTokenDependedTasksInProcess = false
    private var tokenDependedTasksQueue = ThreadSafeArray<TokenDependedTask>()
    
    init(loginManager: LoginManagerProtocol)
    {
        self.loginManager = loginManager
    }
    
    private func startTokenDependedTask(_ completion: @escaping (String) -> Void)
    {
        let task = TokenDependedTask(completion: completion)
        startTokenDependedTask(task)
    }
    
    private func startTokenDependedTask(_ task: TokenDependedTask)
    {
        tokenDependedTasksQueue.append(task)
        
        guard !isTokenDependedTasksInProcess else { return }
        isTokenDependedTasksInProcess = true
        
        loginManager.getAccessToken(withUpdateAttempt: true)
        { [weak self] result in
            
            switch result
            {
                case .success(let token): self?.processTokenDependedTasksQueue(withToken: token)
                case .failure: break
            }
            
            self?.isTokenDependedTasksInProcess = false
        }
    }
    
    private func processTokenDependedTasksQueue(withToken token: String)
    {
        while tokenDependedTasksQueue.count > 0
        {
            tokenDependedTasksQueue.first?.completion(token)
            tokenDependedTasksQueue.dropFirst()
        }
    }
}

// MARK: - Login API

extension XsollaSDK: XsollaSDKProtocol
{
    func authByUsernameAndPassword(username: String,
                                   password: String,
                                   oAuth2Params: OAuth2Params,
                                   completion: @escaping LoginKitCompletion<String>)
    {
        login.authByUsernameAndPassword(username: username,
                                        password: password,
                                        oAuth2Params: oAuth2Params,
                                        completion: completion)
    }
    
    func authByUsernameAndPasswordJWT(username: String,
                                      password: String,
                                      clientId: Int,
                                      scope: String?,
                                      completion: ((Result<Void, Error>) -> Void)?)
    {
        login.authByUsernameAndPasswordJWT(username: username,
                                           password: password,
                                           clientId: clientId,
                                           scope: scope)
        { [weak self] result in
            switch result
            {
                case .success(let tokenInfo): do
                {
                    self?.handleTokenInfo(tokenInfo)
                    completion?(.success(()))
                }
                
                case .failure(let error): completion?(.failure(error))
            }
        }
    }
    
    func getLinkForSocialAuth(providerName: String,
                              oauth2params: OAuth2Params,
                              completion: @escaping LoginKitCompletion<URL>)
    {
        login.getLinkForSocialAuth(providerName: providerName, oauth2params: oauth2params, completion: completion)
    }
    
    func authBySocialNetwork(oAuth2Params: OAuth2Params,
                             providerName: String,
                             socialNetworkAccessToken: String,
                             socialNetworkAccessTokenSecret: String?,
                             socialNetworkOpenId: String?,
                             completion: @escaping LoginKitCompletion<String>)
    {
        login.authBySocialNetwork(oAuth2Params: oAuth2Params,
                                  providerName: providerName,
                                  socialNetworkAccessToken: socialNetworkAccessToken,
                                  socialNetworkAccessTokenSecret: socialNetworkAccessTokenSecret,
                                  socialNetworkOpenId: socialNetworkOpenId,
                                  completion: completion)
    }
    
    func generateJWT(grantType: TokenGrantType,
                     clientId: Int,
                     refreshToken: String?,
                     clientSecret: String?,
                     redirectUri: String?,
                     authCode: String?,
                     completion: ((Result<Void, Error>) -> Void)?)
    {
        login.generateJWT(grantType: grantType,
                          clientId: clientId,
                          refreshToken: refreshToken,
                          clientSecret: clientSecret,
                          redirectUri: redirectUri,
                          authCode: authCode)
        { [weak self] result in
            switch result
            {
                case .success(let tokenInfo): do
                {
                    self?.handleTokenInfo(tokenInfo)
                    completion?(.success(()))
                }
                
                case .failure(let error): completion?(.failure(error))
            }
        }
    }
    
    func registerNewUser(oAuth2Params: OAuth2Params,
                         username: String,
                         password: String,
                         email: String,
                         acceptConsent: Bool?,
                         fields: [String: String]?,
                         promoEmailAgreement: Int?,
                         completion: @escaping LoginKitCompletion<URL?>)
    {
        login.registerNewUser(oAuth2Params: oAuth2Params,
                              username: username,
                              password: password,
                              email: email,
                              acceptConsent: acceptConsent,
                              fields: fields,
                              promoEmailAgreement: promoEmailAgreement,
                              completion: completion)
    }
    
    func resetPassword(loginProjectId: String,
                       username: String,
                       loginUrl: String?,
                       completion: @escaping LoginKitCompletion<Void>)
    {
        login.resetPassword(loginProjectId: loginProjectId,
                            username: username,
                            loginUrl: loginUrl,
                            completion: completion)
    }
    
    func getCurrentUserDetails(completion: ((Result<LoginUserDetails, Error>) -> Void)?)
    {
        startTokenDependedTask
        { [weak self] token in
            
            self?.login.getCurrentUserDetails(accessToken: token)
            { result in
                
                switch result
                {
                    case .success(let userDetails): do
                    {
                        self?.currentUserInfo = userDetails
                        completion?(.success(userDetails))
                    }
                        
                    case .failure(let error): completion?(.failure(error))
                }
            }
        }
    }
}

// MARK: - Inventory API

extension XsollaSDK
{
    func getUserVirtualCurrencyBalance(
        projectId: Int,
        platform: String?,
        completion: @escaping InventoryKitCompletion<[InventoryVirtualCurrencyBalance]>)
    {
        let inventory = self.inventory
        startTokenDependedTask { inventory.getUserVirtualCurrencyBalance(accessToken: $0,
                                                                         projectId: projectId,
                                                                         platform: platform,
                                                                         completion: completion) }
    }
    
    func getUserSubscriptions(projectId: Int,
                              platform: String?,
                              completion: @escaping InventoryKitCompletion<[InventoryUserSubscription]>)
    {
        let inventory = self.inventory
        startTokenDependedTask { inventory.getUserSubscriptions(accessToken: $0,
                                                                projectId: projectId,
                                                                platform: platform,
                                                                completion: completion) }
    }
    
    func consumeItem(projectId: Int,
                     platform: String?,
                     consumingItem: InventoryConsumingItem,
                     completion: @escaping InventoryKitCompletion<Void>)
    {
        let inventory = self.inventory
        startTokenDependedTask { inventory.consumeItem(accessToken: $0,
                                                       projectId: projectId,
                                                       platform: platform,
                                                       consumingItem: consumingItem,
                                                       completion: completion) }
    }
    
    func getUserInventoryItems(projectId: Int,
                               platform: String?,
                               detailedSubscriptions: Bool?,
                               completion: @escaping InventoryKitCompletion<[InventoryItem]>)
    {
        let inventory = self.inventory
        startTokenDependedTask { inventory.getUserInventoryItems(accessToken: $0,
                                                                 projectId: projectId,
                                                                 platform: platform,
                                                                 detailedSubscriptions: detailedSubscriptions,
                                                                 completion: completion) }
    }
}

// MARK: - Store API

extension XsollaSDK
{
    func getItemGroups(projectId: Int, completion: @escaping StoreKitCompletion<[StoreItemGroup]>)
    {
        store.getItemGroups(projectId: projectId, completion: completion)
    }
    
    func getVirtualItems(projectId: Int,
                         filterParams: StoreFilterParams,
                         completion: @escaping StoreKitCompletion<[StoreVirtualItem]>)
    {
        store.getVirtualItems(projectId: projectId, filterParams: filterParams, completion: completion)
    }
    
    func getVirtualCurrency(projectId: Int,
                            filterParams: StoreFilterParams,
                            completion: @escaping StoreKitCompletion<[StoreVirtualCurrency]>)
    {
        store.getVirtualCurrency(projectId: projectId, filterParams: filterParams, completion: completion)
    }
    
    func getVirtualCurrencyPackages(projectId: Int,
                                    filterParams: StoreFilterParams,
                                    completion: @escaping StoreKitCompletion<[StoreCurrencyPackage]>)
    {
        store.getVirtualCurrencyPackages(projectId: projectId, filterParams: filterParams, completion: completion)
    }
    
    func getItemsOfGroup(projectId: Int,
                         externalId: String,
                         filterParams: StoreFilterParams,
                         completion: @escaping StoreKitCompletion<[StoreVirtualItem]>)
    {
        store.getItemsOfGroup(projectId: projectId,
                              externalId: externalId,
                              filterParams: filterParams,
                              completion: completion)
    }
    
    func getBundlesList(projectId: Int,
                        filterParams: StoreFilterParams,
                        completion: @escaping StoreKitCompletion<[StoreBundle]>)
    {
        store.getBundlesList(projectId: projectId, filterParams: filterParams, completion: completion)
    }
    
    func getBundle(projectId: Int, sku: String, completion: @escaping StoreKitCompletion<StoreBundle>)
    {
        store.getBundle(projectId: projectId, sku: sku, completion: completion)
    }
    
    func getOrder(projectId: Int,
                  orderId: String,
                  authorizationType: StoreAuthorizationType,
                  completion: @escaping StoreKitCompletion<StoreOrder>)
    {
        store.getOrder(projectId: projectId,
                       orderId: orderId,
                       authorizationType: authorizationType,
                       completion: completion)
    }
    
    func createOrder(projectId: Int,
                     itemSKU: String,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     paymentProjectSettings: StorePaymentProjectSettings?,
                     customParameters: [String: String]?,
                     completion: @escaping StoreKitCompletion<StoreOrderPaymentInfo>)
    {
        let store = self.store
        startTokenDependedTask { store.createOrder(projectId: projectId,
                                                   accessToken: $0,
                                                   itemSKU: itemSKU,
                                                   currency: currency,
                                                   locale: locale,
                                                   isSandbox: isSandbox,
                                                   paymentProjectSettings: paymentProjectSettings,
                                                   customParameters: customParameters,
                                                   completion: completion) }
    }
    
    func purchaseItemByVirtualCurrency(projectId: Int,
                                       itemSKU: String,
                                       virtualCurrencySKU: String,
                                       platform: String?,
                                       customParameters: Encodable?,
                                       completion: @escaping (StoreKitCompletion<Int>))
    {
        let store = self.store
        startTokenDependedTask { store.purchaseItemByVirtualCurrency(projectId: projectId,
                                                                     accessToken: $0,
                                                                     itemSKU: itemSKU,
                                                                     virtualCurrencySKU: virtualCurrencySKU,
                                                                     platform: platform,
                                                                     customParameters: customParameters,
                                                                     completion: completion) }
    }
    
    func redeemCoupon(projectId: Int,
                      couponCode: String,
                      selectedUnitItems: [String: String]?,
                      completion: @escaping StoreKitCompletion<[StoreCouponRedeemedItem]>)
    {
        let store = self.store
        startTokenDependedTask { store.redeemCoupon(projectId: projectId,
                                                    accessToken: $0,
                                                    couponCode: couponCode,
                                                    selectedUnitItems: selectedUnitItems,
                                                    completion: completion) }
    }
    
    func getCouponRewards(projectId: Int,
                          couponCode: String,
                          completion: @escaping StoreKitCompletion<StoreCouponRewards>)
    {
        let store = self.store
        startTokenDependedTask { store.getCouponRewards(projectId: projectId,
                                                        accessToken: $0,
                                                        couponCode: couponCode,
                                                    completion: completion) }
    }
}

// MARK: - Helpers

extension XsollaSDK
{
    private func handleTokenInfo(_ tokenInfo: AccessTokenInfo)
    {
        var tokenExpireDate: Date?
        if let expiresIn = tokenInfo.expiresIn { tokenExpireDate = Date() + Double(expiresIn) }
        
        loginManager.login(accessToken: tokenInfo.accessToken,
                           refreshToken: tokenInfo.refreshToken,
                           expireDate: tokenExpireDate)
    }
}

extension XsollaSDK
{
    struct TokenDependedTask
    {
        let completion: (String) -> Void
    }
}
