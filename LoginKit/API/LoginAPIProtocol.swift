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
// swiftlint:disable line_length

import Foundation
import XsollaSDKUtilities

typealias LoginAPIError = Error
typealias LoginAPIResult<T> = Result<T, LoginAPIError>

protocol LoginAPIProtocol
{
    // MARK: Authentication
    
    func authByUsernameAndPassword(username: String,
                                   password: String,
                                   oAuth2Params: OAuth2Params,
                                   completion: @escaping (LoginAPIResult<AuthByUsernameAndPasswordResponse>) -> Void)
    
    func authByUsernameAndPasswordJWT(
        username: String,
        password: String,
        clientId: Int,
        scope: String?,
        completion: @escaping (LoginAPIResult<AuthByUsernameAndPasswordJWTResponse>) -> Void)
    
    func getLinkForSocialAuth(providerName: String,
                              clientId: Int,
                              state: String,
                              responseType: String,
                              scope: String?,
                              redirectUri: String?,
                              completion: @escaping (LoginAPIResult<GetLinkForSocialAuthResponse>) -> Void)
    
    func authBySocialNetwork(oAuth2Params: OAuth2Params,
                             providerName: String,
                             socialNetworkAccessToken: String,
                             socialNetworkAccessTokenSecret: String?,
                             socialNetworkOpenId: String?,
                             completion: @escaping (LoginAPIResult<AuthBySocialNetworkResponse>) -> Void)
    
    func generateJWT(grantType: String,
                     clientId: Int,
                     refreshToken: String?,
                     clientSecret: String?,
                     redirectUri: String?,
                     authCode: String?,
                     completion: @escaping (LoginAPIResult<GenerateJWTResponse>) -> Void)
    
    func registerNewUser(oAuth2Params: OAuth2Params,
                         username: String,
                         password: String,
                         email: String,
                         acceptConsent: Bool?,
                         fields: [String: String]?,
                         promoEmailAgreement: Int?,
                         completion: @escaping (LoginAPIResult<RegisterNewUserResponse>) -> Void)
    
    func resetPassword(loginProjectId: String,
                       username: String,
                       loginUrl: String?,
                       completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    // MARK: - User Account: User Profile
    
    func getCurrentUserDetails(accessToken: String,
                               completion: @escaping (LoginAPIResult<GetCurrentUserDetailsResponse>) -> Void)
    
    func updateCurrentUserDetails(accessToken: String,
                                  birthday: String?,
                                  firstName: String?,
                                  lastName: String?,
                                  gender: String?,
                                  nickname: String?,
                                  completion: @escaping (LoginAPIResult<UpdateCurrentUserDetailsResponse>) -> Void)
    
    func getUserEmail(accessToken: String,
                      completion: @escaping (LoginAPIResult<GetUserEmailResponse>) -> Void)
    
    func deleteUserPicture(accessToken: String, completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    func uploadUserPicture(accessToken: String,
                           imageURL: URL,
                           completion: @escaping (LoginAPIResult<UploadUserPictureResponse>) -> Void)
    
    func getCurrentUserPhone(accessToken: String,
                             completion: @escaping (LoginAPIResult<GetCurrentUserPhoneResponse>) -> Void)
    
    func updateCurrentUserPhone(accessToken: String,
                                phoneNumber: String,
                                completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    func deleteCurrentUserPhone(accessToken: String,
                                phoneNumber: String,
                                completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    // MARK: User Account: User Friends
    
    func getCurrentUserFriends(accessToken: String,
                               listType: String,
                               sortType: String,
                               sortOrder: String,
                               after: String?,
                               limit: Int?,
                               completion: @escaping (LoginAPIResult<GetCurrentUserFriendsResponse>) -> Void)
    
    func updateCurrentUserFriends(accessToken: String,
                                  action: String,
                                  userID: String,
                                  completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    // MARK: User Account: Social Networks
    
    func getLinkedNetworks(accessToken: String,
                           completion: @escaping (LoginAPIResult<GetLinkedNetworksResponse>) -> Void)
    
    func getURLToLinkSocialNetworkToAccount(
        accessToken: String,
        providerName: String,
        loginURL: String,
        completion: @escaping (LoginAPIResult<GetURLToLinkSocialNetworkToAccountResponse>) -> Void)
    
    func getSocialNetworkFriends(accessToken: String,
                                 platform: String,
                                 offset: Int,
                                 limit: Int,
                                 withLoginId: Bool,
                                 completion: @escaping (LoginAPIResult<GetSocialNetworkFriendsResponse>) -> Void)
    
    func updateSocialNetworkFriends(accessToken: String,
                                    platform: String,
                                    completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    // MARK: - User Attributes
    
    func getClientUserAttributes(accessToken: String,
                                 keys: [String]?,
                                 publisherProjectId: Int?,
                                 userId: String?,
                                 completion: @escaping (LoginAPIResult<GetClientUserAttributesResponse>) -> Void)
    
    func getClientUserReadOnlyAttributes(accessToken: String,
                                         keys: [String]?,
                                         publisherProjectId: Int?,
                                         userId: String?,
                                         completion: @escaping (LoginAPIResult<GetClientUserReadOnlyAttributesResponse>) -> Void)
    
    func updateClientUserAttributes(accessToken: String,
                                    attributes: [UpdateClientUserAttributesRequest.Body.Attribute]?,
                                    publisherProjectId: Int?,
                                    removingKeys: [String]?,
                                    completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
}
