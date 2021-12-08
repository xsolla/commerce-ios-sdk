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
import XsollaSDKPaymentsKit

protocol XsollaSDKAuthorizationErrorDelegate: AnyObject
{
    func xsollaSDK(_ xsollaSDK: XsollaSDK, didFailAuthorizationWithError error: Error)
}

protocol XsollaSDKBalanceUpdatesListener: AnyObject
{
    func didRecieveCurrencyBalance(currency1Balance: VirtualCurrencyBalance, currency2Balance: VirtualCurrencyBalance) 
}

final class XsollaSDK
{
    let accessTokenProvider: AccessTokenProvider
    
    weak var authorizationErrorDelegate: XsollaSDKAuthorizationErrorDelegate?

    var balanceFetcher: VirtualCurrencyBalanceFetcherProtocol?
    weak var balanceUpdatesListener: XsollaSDKBalanceUpdatesListener?
    
    private var login: LoginKit { .shared }
    private var inventory: InventoryKit { .shared }
    private var store: StoreKit { .shared }
    private var payments: PaymentsKit { .shared }

    @Atomic private var isTokenDependedTasksInProcess = false
    private var tokenDependentTasksQueue = ThreadSafeArray<TokenDependentTask>()
    
    init(accessTokenProvider: AccessTokenProvider)
    {
        self.accessTokenProvider = accessTokenProvider
    }
    
    private func startTokenDependentTask(_ completion: @escaping (String?) -> Void)
    {
        let task = TokenDependentTask(completion: completion)
        startTokenDependentTask(task)
    }
    
    private func startTokenDependentTask(_ task: TokenDependentTask)
    {
        tokenDependentTasksQueue.append(task)
        
        guard !isTokenDependedTasksInProcess else { return }
        isTokenDependedTasksInProcess = true
        
        accessTokenProvider.getAccessToken
        { [weak self] result in
            
            switch result
            {
                case .success(let token): self?.processTokenDependedTasksQueue(withToken: token)
                case .failure: self?.invalidateQueue()
            }
            
            self?.isTokenDependedTasksInProcess = false
        }
    }
    
    private func processTokenDependedTasksQueue(withToken token: String)
    {
        while tokenDependentTasksQueue.count > 0
        {
            tokenDependentTasksQueue.first?.completion(token)
            tokenDependentTasksQueue.dropFirst()
        }
    }
    
    private func invalidateQueue()
    {
        while tokenDependentTasksQueue.count > 0
        {
            tokenDependentTasksQueue.first?.completion(nil)
            tokenDependentTasksQueue.dropFirst()
        }
    }

    func requestBalanceUpdate()
    {
        balanceFetcher?.fetchBalanceData()
    }
}

extension XsollaSDK: VirtualCurrencyBalanceFetcherDelegate
{
    func didRecieveCurrencyBalance(currency1Balance: VirtualCurrencyBalance, currency2Balance: VirtualCurrencyBalance)
    {
        balanceUpdatesListener?.didRecieveCurrencyBalance(currency1Balance: currency1Balance,
                                                          currency2Balance: currency2Balance)
    }
}

// MARK: - Login API

extension XsollaSDK: XsollaSDKProtocol
{
    @available(iOS 13.4, *)
    func authBySocialNetwork(_ providerName: String,
                             oAuth2Params: OAuth2Params,
                             jwtParams: JWTGenerationParams,
                             presentationContextProvider: WebAuthenticationSession.PresentationContextProviding,
                             completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        login.authBySocialNetwork(providerName,
                                  oAuth2Params: oAuth2Params,
                                  jwtParams: jwtParams,
                                  presentationContextProvider: presentationContextProvider,
                                  completion: completion)
    }

    func authByUsernameAndPassword(username: String,
                                   password: String,
                                   oAuth2Params: OAuth2Params,
                                   jwtParams: JWTGenerationParams,
                                   completion: @escaping LoginKitCompletion<AccessTokenInfo>)
    {
        login.authByUsernameAndPassword(username: username,
                                        password: password,
                                        oAuth2Params: oAuth2Params,
                                        jwtParams: jwtParams,
                                        completion: completion)
    }
    
    func getLinkForSocialAuth(providerName: String,
                              oAuth2Params: OAuth2Params,
                              completion: @escaping LoginKitCompletion<URL>)
    {
        login.getLinkForSocialAuth(providerName: providerName, oAuth2Params: oAuth2Params, completion: completion)
    }
    
    func authBySocialNetwork(oAuth2Params: OAuth2Params,
                             jwtParams: JWTGenerationParams,
                             providerName: String,
                             socialNetworkAccessToken: String,
                             socialNetworkAccessTokenSecret: String?,
                             socialNetworkOpenId: String?,
                             completion: @escaping LoginKitCompletion<AccessTokenInfo>)
    {
        login.authBySocialNetwork(oAuth2Params: oAuth2Params,
                                  jwtParams: jwtParams,
                                  providerName: providerName,
                                  socialNetworkAccessToken: socialNetworkAccessToken,
                                  socialNetworkAccessTokenSecret: socialNetworkAccessTokenSecret,
                                  socialNetworkOpenId: socialNetworkOpenId,
                                  completion: completion)
    }
    
    func generateJWT(with authCode: String?,
                     jwtParams: JWTGenerationParams,
                     completion: ((Result<AccessTokenInfo, Error>) -> Void)?)
    {
        login.generateJWT(with: authCode, jwtParams: jwtParams)
        { [weak self] result in
            switch result
            {
                case .success(let tokenInfo): do
                {
                    completion?(.success(tokenInfo))
                }
                
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }

    func registerNewUser(params: RegisterNewUserParams,
                         oAuth2Params: OAuth2Params,
                         jwtParams: JWTGenerationParams,
                         completion: ((Result<AccessTokenInfo?, Error>) -> Void)?)
    {
        login.registerNewUser(params: params, oAuth2Params: oAuth2Params, jwtParams: jwtParams)
        { [weak self] result in
            switch result
            {
                case .success(let tokenInfo): completion?(.success(tokenInfo))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func resetPassword(loginProjectId: String,
                       username: String,
                       loginUrl: String?,
                       completion: ((Result<Void, Error>) -> Void)?)
    {
        login.resetPassword(loginProjectId: loginProjectId,
                            username: username,
                            loginUrl: loginUrl)
        { [weak self] result in
            switch result
            {
                case .success: completion?(.success(()))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func startAuthByEmail(oAuth2Params: OAuth2Params,
                          email: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          completion: ((Result<LoginOperationId, Error>) -> Void)?)
    {
        login.startAuthByEmail(oAuth2Params: oAuth2Params, email: email, linkUrl: linkUrl, sendLink: sendLink)
        { [weak self] result in
            switch result
            {
                case .success(let operationId): completion?(.success(operationId))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func completeAuthByEmail(clientId: Int,
                             code: String,
                             email: String,
                             operationId: LoginOperationId,
                             jwtParams: JWTGenerationParams,
                             completion: ((Result<AccessTokenInfo, Error>) -> Void)?)
    {
        login.completeAuthByEmail(clientId: clientId,
                                  code: code,
                                  email: email,
                                  operationId: operationId,
                                  jwtParams: jwtParams)
        { [weak self] result in
            switch result
            {
                case .success(let tokenInfo): completion?(.success(tokenInfo))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func startAuthByPhone(oAuth2Params: OAuth2Params,
                          phoneNumber: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          completion: ((Result<LoginOperationId, Error>) -> Void)?)
    {
        login.startAuthByPhone(oAuth2Params: oAuth2Params,
                               phoneNumber: phoneNumber,
                               linkUrl: linkUrl,
                               sendLink: sendLink)
        { [weak self] result in
            switch result
            {
                case .success(let operationId): completion?(.success(operationId))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func completeAuthByPhone(clientId: Int,
                             code: String,
                             phoneNumber: String,
                             operationId: LoginOperationId,
                             jwtParams: JWTGenerationParams,
                             completion: ((Result<AccessTokenInfo, Error>) -> Void)?)
    {
        login.completeAuthByPhone(clientId: clientId,
                                  code: code,
                                  phoneNumber: phoneNumber,
                                  operationId: operationId,
                                  jwtParams: jwtParams)
        { [weak self] result in
            switch result
            {
                case .success(let tokenInfo): completion?(.success(tokenInfo))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }

    func getConfirmationCode(projectId: String,
                             login: String,
                             operationId: String,
                             completion: ((Result<String, Error>) -> Void)?)
    {
        self.login.getConfirmationCode(projectId: projectId,
                                       login: login,
                                       operationId: operationId)
        { [weak self] result in
            switch result
            {
                case .success(let code): completion?(.success(code))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }

    func resendConfirmationLink(clientId: Int,
                                redirectUri: String,
                                state: String,
                                username: String,
                                completion: ((Result<Void, Error>) -> Void)?)
    {
        self.login.resendConfirmationLink(clientId: clientId,
                                          redirectUri: redirectUri,
                                          state: state,
                                          username: username)
        { [weak self] result in
            switch result
            {
                case .success: completion?(.success(()))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }

    func authWithDeviceId(deviceId: String,
                          device: String,
                          oAuth2Params: OAuth2Params,
                          jwtParams: JWTGenerationParams,
                          completion: ((Result<AccessTokenInfo, Error>) -> Void)?)
    {
        login.authWithDeviceId(deviceId: deviceId, device: device, oAuth2Params: oAuth2Params, jwtParams: jwtParams)
        { [weak self] result in

            switch result
            {
                case .success(let tokenInfo): completion?(.success(tokenInfo))
                case .failure(let error): do
                {
                    self?.processError(error)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func getUserConnectedDevices(completion: ((Result<[DeviceInfo], Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getUserDevices(accessToken: token)
            { [weak self] result in
                
                switch result
                {
                    case .success(let devicesInfo): do
                    {
                        completion?(.success(devicesInfo))
                    }
                    
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func linkDeviceToAccount(device: String,
                             deviceId: String,
                             completion: ((Result<Void, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.linkDeviceToAccount(device: device, deviceId: deviceId, accessToken: token)
            { [weak self] result in
                switch result
                {
                    case .success: do
                    {
                        completion?(.success(()))
                    }
                    
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func unlinkDeviceFromAccount(deviceId: String,
                                 completion: ((Result<Void, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.unlinkDeviceFromAccount(deviceId: deviceId, accessToken: token)
            { [weak self] result in
                switch result
                {
                    case .success: do
                    {
                        completion?(.success(()))
                    }
                        
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }

    func addUsernameAndPassword(username: String,
                                password: String,
                                email: String,
                                promoEmailAgreement: Bool,
                                redirectUri: String?,
                                completion: ((Result<Bool, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }

            self?.login.addUsernameAndPassword(username: username,
                                               password: password,
                                               email: email,
                                               promoEmailAgreement: promoEmailAgreement,
                                               accessToken: token,
                                               redirectUri: redirectUri)
            { [weak self] result in
                switch result
                {
                case .success(let emailConfirmationRequired): completion?(.success(emailConfirmationRequired))
                case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }

    func getCurrentUserDetails(completion: ((Result<UserProfileDetails, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getCurrentUserDetails(accessToken: token)
            { result in
                
                switch result
                {
                    case .success(let userDetails): do
                    {
                        completion?(.success(userDetails))
                    }
                        
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func updateCurrentUserDetails(birthday: Date?,
                                  firstName: String?,
                                  lastName: String?,
                                  nickname: String?,
                                  gender: UserProfileDetails.Gender?,
                                  completion: ((Result<UserProfileDetails, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.updateCurrentUserDetails(accessToken: token,
                                                 birthday: birthday,
                                                 firstName: firstName,
                                                 lastName: lastName,
                                                 nickname: nickname,
                                                 gender: gender)
            { result in
                
                switch result
                {
                    case .success(let userDetails): do
                    {
                        completion?(.success(userDetails))
                    }
                        
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func getUserEmail(completion: ((Result<String?, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getUserEmail(accessToken: token)
            { result in
                
                switch result
                {
                    case .success(let email): completion?(.success(email))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func deleteUserPicture(completion: ((Result<Void, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.deleteUserPicture(accessToken: token)
            { result in
                
                switch result
                {
                    case .success: completion?(.success(()))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func uploadUserPicture(imageURL: URL, completion: ((Result<String, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.uploadUserPicture(accessToken: token, imageURL: imageURL)
            { result in
                
                switch result
                {
                    case .success(let urlString): completion?(.success(urlString))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func getCurrentUserPhone(completion: ((Result<String?, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getCurrentUserPhone(accessToken: token)
            { result in
                
                switch result
                {
                    case .success(let phone): completion?(.success(phone))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func updateCurrentUserPhone(phoneNumber: String, completion: ((Result<Void, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.updateCurrentUserPhone(accessToken: token, phoneNumber: phoneNumber)
            { result in
                
                switch result
                {
                    case .success: completion?(.success(()))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func deleteCurrentUserPhone(phoneNumber: String, completion: ((Result<Void, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.deleteCurrentUserPhone(accessToken: token, phoneNumber: phoneNumber)
            { result in
                
                switch result
                {
                    case .success: completion?(.success(()))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func getCurrentUserFriends(listType: FriendsListType,
                               sortType: FriendsListSortType,
                               sortOrderType: FriendsListOrderType,
                               after: String?,
                               limit: Int?,
                               completion: ((Result<FriendsList, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getCurrentUserFriends(accessToken: token,
                                              listType: listType,
                                              sortType: sortType,
                                              sortOrderType: sortOrderType,
                                              after: after,
                                              limit: limit)
            { result in
                
                switch result
                {
                    case .success(let friendsList): completion?(.success(friendsList))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func updateCurrentUserFriends(actionType: FriendsListUpdateAction,
                                  userID: String,
                                  completion: ((Result<Void, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.updateCurrentUserFriends(accessToken: token, actionType: actionType, userID: userID)
            { result in
                
                switch result
                {
                    case .success: completion?(.success(()))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func getLinkedSocialNetworks(completion: ((Result<[UserSocialNetworkInfo], Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getLinkedNetworks(accessToken: token)
            { result in
                
                switch result
                {
                    case .success(let userSocialNetworks): completion?(.success(userSocialNetworks))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }

    func getSocialNetworkLinkingURL(for socialNetwork: SocialNetwork,
                                    callbackURL: String,
                                    completion: ((Result<URL, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }

            self?.login.getURLToLinkSocialNetworkToAccount(accessToken: token,
                                                           providerName: socialNetwork.rawValue,
                                                           loginURL: callbackURL)
            { result in

                switch result
                {
                    case .success(let string): do
                    {
                        guard let url = URL(string: string) else
                        {
                            completion?(.failure(LoginKitError.failedURLExtraction))
                            return
                        }

                        completion?(.success(url))
                    }

                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }

    func getClientUserAttributes(keys: [String]?,
                                 publisherProjectId: Int?,
                                 userId: String?,
                                 completion: ((Result<[UserAttribute], Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getClientUserAttributes(accessToken: token,
                                                keys: keys,
                                                publisherProjectId: publisherProjectId,
                                                userId: userId)
            { result in
                
                switch result
                {
                    case .success(let userAttributes): completion?(.success(userAttributes))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func getClientUserReadOnlyAttributes(keys: [String]?,
                                         publisherProjectId: Int?,
                                         userId: String?,
                                         completion: ((Result<[UserAttribute], Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.getClientUserReadOnlyAttributes(accessToken: token,
                                                        keys: keys,
                                                        publisherProjectId: publisherProjectId,
                                                        userId: userId)
            { result in
                
                switch result
                {
                    case .success(let userAttributes): completion?(.success(userAttributes))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    func updateClientUserAttributes(attributes: [UserAttribute]?,
                                    publisherProjectId: Int?,
                                    removingKeys: [String]?,
                                    completion: ((Result<Void, Error>) -> Void)?)
    {
        startTokenDependentTask
        { [weak self] token in
            guard let token = token else { completion?(.failure(LoginKitError.invalidToken)); return }
            
            self?.login.updateClientUserAttributes(accessToken: token,
                                                   attributes: attributes,
                                                   publisherProjectId: publisherProjectId,
                                                   removingKeys: removingKeys)
            { result in
                
                switch result
                {
                    case .success: completion?(.success(()))
                    case .failure(let error): do
                    {
                        self?.processError(error)
                        completion?(.failure(error))
                    }
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
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            inventory.getUserVirtualCurrencyBalance(accessToken: token,
                                                    projectId: projectId,
                                                    platform: platform,
                                                    completion: completion) }
    }
    
    func getUserSubscriptions(projectId: Int,
                              platform: String?,
                              completion: @escaping InventoryKitCompletion<[InventoryUserSubscription]>)
    {
        let inventory = self.inventory
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            inventory.getUserSubscriptions(accessToken: token,
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
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            inventory.consumeItem(accessToken: token,
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
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            inventory.getUserInventoryItems(accessToken: token,
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
                     quantity: Int = 1,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     paymentProjectSettings: StorePaymentProjectSettings?,
                     customParameters: [String: String]?,
                     completion: @escaping StoreKitCompletion<StoreOrderPaymentInfo>)
    {
        let store = self.store
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            store.createOrder(projectId: projectId,
                              accessToken: token,
                              itemSKU: itemSKU,
                              quantity: quantity,
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
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            store.purchaseItemByVirtualCurrency(projectId: projectId,
                                                accessToken: token,
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
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            store.redeemCoupon(projectId: projectId,
                               accessToken: token,
                               couponCode: couponCode,
                               selectedUnitItems: selectedUnitItems,
                               completion: completion) }
    }
    
    func getCouponRewards(projectId: Int,
                          couponCode: String,
                          completion: @escaping StoreKitCompletion<StoreCouponRewards>)
    {
        let store = self.store
        startTokenDependentTask
        { token in guard let token = token else { completion(.failure(LoginKitError.invalidToken)); return }
            
            store.getCouponRewards(projectId: projectId,
                                   accessToken: token,
                                   couponCode: couponCode,
                                   completion: completion) }
    }
}

// MARK: - Payments API

extension XsollaSDK
{
    func createPaymentUrl(paymentToken: String, isSandbox: Bool) -> URL?
    {
        self.payments.createPaymentUrl(paymentToken: paymentToken, isSandbox: isSandbox)
    }
}

// MARK: - Helpers

extension XsollaSDK
{
    private func processError(_ error: Error)
    {
        switch error
        {
            case LoginKitError.invalidToken:
                authorizationErrorDelegate?.xsollaSDK(self, didFailAuthorizationWithError: error)
            
            default: break
        }
    }
}

extension XsollaSDK
{
    struct TokenDependentTask
    {
        let completion: (String?) -> Void
    }
}
