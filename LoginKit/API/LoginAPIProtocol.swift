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

    func logUserOut(accessToken: String, sessionType: LogoutSessionType, completion: @escaping (LoginAPIResult<Void>) -> Void)

    func authByUsernameAndPassword(username: String,
                                   password: String,
                                   oAuth2Params: OAuth2Params,
                                   completion: @escaping (LoginAPIResult<AuthByUsernameAndPasswordResponse>) -> Void)
    
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

    func deleteLinkedNetwork(accessToken: String,
                             providerName: String,
                             completion: @escaping (LoginAPIResult<Void>) -> Void)
    
    func generateJWT(with authCode: String?,
                     jwtParams: JWTGenerationParams,
                     completion: @escaping (LoginAPIResult<GenerateJWTResponse>) -> Void)
    
    func registerNewUser(params: RegisterNewUserParams,
                         oAuth2Params: OAuth2Params,
                         locale: String?,
                         completion: @escaping (LoginAPIResult<RegisterNewUserResponse>) -> Void)
    
    func resetPassword(loginProjectId: String,
                       username: String,
                       loginUrl: String?,
                       locale: String?,
                       completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    func startAuthByEmail(oAuth2Params: OAuth2Params,
                          email: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          locale: String?,
                          completion: @escaping (LoginAPIResult<StartAuthByEmailResponse>) -> Void)
    
    func completeAuthByEmail(clientId: Int,
                             code: String,
                             email: String,
                             operationId: String,
                             completion: @escaping (LoginAPIResult<CompleteAuthByEmailResponse>) -> Void)
    
    func startAuthByPhone(oAuth2Params: OAuth2Params,
                          phoneNumber: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          completion: @escaping (LoginAPIResult<StartAuthByPhoneResponse>) -> Void)
    
    func completeAuthByPhone(clientId: Int,
                             code: String,
                             operationId: String,
                             phoneNumber: String,
                             completion: @escaping (LoginAPIResult<CompleteAuthByPhoneResponse>) -> Void)

    func getConfirmationCode(projectId: String,
                             login: String,
                             operationId: String,
                             completion: @escaping (LoginAPIResult<String>) -> Void)

    func resendConfirmationLink(clientId: Int,
                                redirectUri: String,
                                state: String,
                                username: String,
                                locale: String?,
                                completion: @escaping (LoginAPIResult<Void>) -> Void)

    func authWithDeviceId(oAuth2Params: OAuth2Params,
                          device: String,
                          deviceId: String,
                          completion: @escaping (LoginAPIResult<AuthWithDeviceIdResponse>) -> Void)
    
    func getUserDevices(accessToken: String, completion: @escaping (LoginAPIResult<GetUserDevicesResponse>) -> Void)
    
    func linkDeviceToAccount(device: String,
                             deviceId: String,
                             accessToken: String,
                             completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    
    func unlinkDeviceFromAccount(deviceId: String,
                                 accessToken: String,
                                 completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)

    func addUsernameAndPassword(accessToken: String,
                                username: String,
                                password: String,
                                email: String,
                                promoEmailAgreement: Bool,
                                redirectUri: String?,
                                completion: @escaping (LoginAPIResult<AddUsernameAndPasswordResponse>) -> Void)

    func createCodeForLinkingAccounts(accessToken: String,
                                      completion: @escaping (LoginAPIResult<String>) -> Void)

    // MARK: - User Account: User Profile

    func getUserPublicProfile(userId: String,
                              accessToken: String,
                              completion: @escaping (LoginAPIResult<GetUserPublicProfileResponse>) -> Void)

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

    func searchUsersByNickname(nickname: String,
                               accessToken: String,
                               offset: Int?,
                               limit: Int?,
                               completion: @escaping (LoginAPIResult<SearchUsersByNicknameResponse>) -> Void)

    // MARK: User Account: Social Networks

    func getLinksForSocialAuth(accessToken: String,
                               locale: String?,
                               completion: @escaping (LoginAPIResult<GetLinksForSocialAuthResponse>) -> Void)
    
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

    func checkUserAge(birthday: String,
                      accessToken: String,
                      loginId: String,
                      completion: @escaping (LoginAPIResult<Bool>) -> Void)
}
