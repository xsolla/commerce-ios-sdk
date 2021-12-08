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

class LoginAPI
{
    let requestPerformer: RequestPerformer
    let responseProcessor: ResponseProcessor
    
    init(requestPerformer: RequestPerformer, responseProcessor: ResponseProcessor)
    {
        logger.debug(.initialization, domain: .loginKit) { String(describing: Self.self) }
        
        self.requestPerformer = requestPerformer
        self.responseProcessor = responseProcessor
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .loginKit) { deinitingType }
    }
}

extension LoginAPI: LoginAPIProtocol
{
    func logUserOut(accessToken: String, sessionType: LogoutSessionType, completion: @escaping (LoginAPIResult<Void>) -> Void)
    {
        LogUserOutAPIProxy(configuration).logUserOut(accessToken: accessToken, sessionType: sessionType, completion: completion)
    }

    func authByUsernameAndPassword(username: String,
                                   password: String,
                                   oAuth2Params: OAuth2Params,
                                   completion: @escaping (LoginAPIResult<AuthByUsernameAndPasswordResponse>) -> Void)
    {
        AuthByUsernameAndPasswordAPIProxy(configuration).authByUsernameAndPassword(username: username,
                                                                                   password: password,
                                                                                   oAuth2Params: oAuth2Params,
                                                                                   completion: completion)
    }
    
    func getLinkForSocialAuth(providerName: String,
                              clientId: Int,
                              state: String,
                              responseType: String,
                              scope: String?,
                              redirectUri: String?,
                              completion: @escaping (LoginAPIResult<GetLinkForSocialAuthResponse>) -> Void)
    {
        GetLinkForSocialAuthAPIProxy(configuration).getLinkForSocialAuth(providerName: providerName,
                                                                         clientId: clientId,
                                                                         state: state,
                                                                         responseType: responseType,
                                                                         scope: scope,
                                                                         redirectUri: redirectUri,
                                                                         completion: completion)
    }
    
    func authBySocialNetwork(oAuth2Params: OAuth2Params,
                             providerName: String,
                             socialNetworkAccessToken: String,
                             socialNetworkAccessTokenSecret: String?,
                             socialNetworkOpenId: String?,
                             completion: @escaping (LoginAPIResult<AuthBySocialNetworkResponse>) -> Void)
    {
        AuthBySocialNetworkAPIProxy(configuration).authBySocialNetwork(
            oAuth2Params: oAuth2Params,
            providerName: providerName,
            socialNetworkAccessToken: socialNetworkAccessToken,
            socialNetworkAccessTokenSecret: socialNetworkAccessTokenSecret,
            socialNetworkOpenId: socialNetworkOpenId,
            completion: completion)
    }
    
    func generateJWT(with authCode: String?,
                     jwtParams: JWTGenerationParams,
                     completion: @escaping (LoginAPIResult<GenerateJWTResponse>) -> Void)
    {
        GenerateJWTAPIProxy(configuration).generateJWT(with: authCode, jwtParams: jwtParams, completion: completion)
    }
    
    func registerNewUser(params: RegisterNewUserParams,
                         oAuth2Params: OAuth2Params,
                         completion: @escaping (LoginAPIResult<RegisterNewUserResponse>) -> Void)
    {
        RegisterNewUserAPIProxy(configuration).registerNewUser(params: params,
                                                               oAuth2Params: oAuth2Params,
                                                               completion: completion)
    }
    
    func resetPassword(loginProjectId: String,
                       username: String,
                       loginUrl: String?,
                       completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        ResetPasswordAPIProxy(configuration).resetPassword(loginProjectId: loginProjectId,
                                                           username: username,
                                                           loginUrl: loginUrl,
                                                           completion: completion)
    }
    
    func startAuthByEmail(oAuth2Params: OAuth2Params,
                          email: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          completion: @escaping (LoginAPIResult<StartAuthByEmailResponse>) -> Void)
    {
        StartAuthByEmailAPIProxy(configuration).startAuthByEmail(oAuth2Params: oAuth2Params,
                                                                 email: email,
                                                                 linkUrl: linkUrl,
                                                                 sendLink: sendLink,
                                                                 completion: completion)
    }
    
    func completeAuthByEmail(clientId: Int,
                             code: String,
                             email: String,
                             operationId: String,
                             completion: @escaping (LoginAPIResult<CompleteAuthByEmailResponse>) -> Void)
    {
        CompleteAuthByEmailAPIProxy(configuration).completeAuthByEmail(clientId: clientId,
                                                                       code: code,
                                                                       email: email,
                                                                       operationId: operationId,
                                                                       completion: completion)
    }
    
    func startAuthByPhone(oAuth2Params: OAuth2Params,
                          phoneNumber: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          completion: @escaping (LoginAPIResult<StartAuthByPhoneResponse>) -> Void)
    {
        StartAuthByPhoneAPIProxy(configuration).startAuthByPhone(oAuth2Params: oAuth2Params,
                                                                 phoneNumber: phoneNumber,
                                                                 linkUrl: linkUrl,
                                                                 sendLink: sendLink,
                                                                 completion: completion)
    }
    
    func completeAuthByPhone(clientId: Int,
                             code: String,
                             operationId: String,
                             phoneNumber: String,
                             completion: @escaping (LoginAPIResult<CompleteAuthByPhoneResponse>) -> Void)
    {
        CompleteAuthByPhoneAPIProxy(configuration).completeAuthByPhone(clientId: clientId,
                                                                       code: code,
                                                                       operationId: operationId,
                                                                       phoneNumber: phoneNumber,
                                                                       completion: completion)
    }

    func getConfirmationCode(projectId: String,
                             login: String,
                             operationId: String,
                             completion: @escaping (LoginAPIResult<String>) -> Void)
    {
        GetConfirmationCodeAPIProxy(configuration).getConfirmationCode(projectId: projectId,
                                                                       login: login,
                                                                       operationId: operationId,
                                                                       completion: completion)
    }

    func resendConfirmationLink(clientId: Int,
                                redirectUri: String,
                                state: String,
                                username: String,
                                completion: @escaping (LoginAPIResult<Void>) -> Void)
    {
        ResendConfirmationLinkAPIProxy(configuration).resendConfirmationLink(clientId: clientId,
                                                                             redirectUri: redirectUri,
                                                                             state: state,
                                                                             username: username,
                                                                             completion: completion)
    }

    func authWithDeviceId(oAuth2Params: OAuth2Params,
                          device: String,
                          deviceId: String,
                          completion: @escaping (LoginAPIResult<AuthWithDeviceIdResponse>) -> Void)
    {
        AuthWithDeviceIdAPIProxy(configuration).authWithDeviceId(oAuth2Params: oAuth2Params, device: device, deviceId: deviceId, completion: completion)
    }
    
    func getUserDevices(accessToken: String, completion: @escaping (LoginAPIResult<GetUserDevicesResponse>) -> Void)
    {
        GetUserDevicesAPIProxy(configuration).getUserDevices(accessToken: accessToken, completion: completion)
    }
    
    func linkDeviceToAccount(device: String,
                             deviceId: String,
                             accessToken: String,
                             completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        LinkDeviceToAccountAPIProxy(configuration).linkDeviceToAccount(device: device,
                                                                       deviceId: deviceId,
                                                                       accessToken: accessToken,
                                                                       completion: completion)
    }
    
    func unlinkDeviceFromAccount(deviceId: String,
                                 accessToken: String,
                                 completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        UnlinkDeviceFromAccountAPIProxy(configuration).unlinkDeviceFromAccount(deviceId: deviceId,
                                                                               accessToken: accessToken,
                                                                               completion: completion)
    }

    func addUsernameAndPassword(accessToken: String,
                                username: String,
                                password: String,
                                email: String,
                                promoEmailAgreement: Bool,
                                redirectUri: String?,
                                completion: @escaping (LoginAPIResult<AddUsernameAndPasswordResponse>) -> Void)
    {
        AddUsernameAndPasswordAPIProxy(configuration).addUsernameAndPassword(accessToken: accessToken,
                                                                             username: username,
                                                                             password: password,
                                                                             email: email,
                                                                             completion: completion)
    }

    func createCodeForLinkingAccounts(accessToken: String,
                                      completion: @escaping (LoginAPIResult<String>) -> Void)
    {
        CreateCodeForLinkingAccountsAPIProxy(configuration).createCodeForLinkingAccounts(accessToken: accessToken,
                                                                                         completion: completion)
    }

    // MARK: - User Account API

    func getUserPublicProfile(userId: String,
                              accessToken: String,
                              completion: @escaping (LoginAPIResult<GetUserPublicProfileResponse>) -> Void)
    {
        GetUserPublicProfileAPIProxy(configuration).getUserPublicProfile(userId: userId,
                                                                         accessToken: accessToken,
                                                                         completion: completion)
    }

    func getCurrentUserDetails(accessToken: String,
                               completion: @escaping (LoginAPIResult<GetCurrentUserDetailsResponse>) -> Void)
    {
        GetCurrentUserDetailsAPIProxy(configuration).getCurrentUserDetails(accessToken: accessToken,
                                                                           completion: completion)
    }
    
    func updateCurrentUserDetails(accessToken: String,
                                  birthday: String?,
                                  firstName: String?,
                                  lastName: String?,
                                  gender: String?,
                                  nickname: String?,
                                  completion: @escaping (LoginAPIResult<UpdateCurrentUserDetailsResponse>) -> Void)
    {
        UpdateCurrentUserDetailsAPIProxy(configuration).updateCurrentUserDetails(accessToken: accessToken,
                                                                                 birthday: birthday,
                                                                                 firstName: firstName,
                                                                                 lastName: lastName,
                                                                                 gender: gender,
                                                                                 nickname: nickname,
                                                                                 completion: completion)
    }
    
    func getUserEmail(accessToken: String,
                      completion: @escaping (LoginAPIResult<GetUserEmailResponse>) -> Void)
    {
        GetUserEmailAPIProxy(configuration).getUserEmail(accessToken: accessToken, completion: completion)
    }
    
    func deleteUserPicture(accessToken: String, completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        DeleteUserPictureAPIProxy(configuration).deleteUserPicture(accessToken: accessToken, completion: completion)
    }
    
    func uploadUserPicture(accessToken: String,
                           imageURL: URL,
                           completion: @escaping (LoginAPIResult<UploadUserPictureResponse>) -> Void)
    {
        UploadUserPictureAPIProxy(configuration).uploadUserPicture(accessToken: accessToken,
                                                                   imageURL: imageURL,
                                                                   completion: completion)
    }
    
    func getCurrentUserPhone(accessToken: String,
                             completion: @escaping (LoginAPIResult<GetCurrentUserPhoneResponse>) -> Void)
    {
        GetCurrentUserPhoneAPIProxy(configuration).getCurrentUserPhone(accessToken: accessToken, completion: completion)
    }
    
    func updateCurrentUserPhone(accessToken: String,
                                phoneNumber: String,
                                completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        UpdateCurrentUserPhoneAPIProxy(configuration).updateCurrentUserPhone(accessToken: accessToken,
                                                                             phoneNumber: phoneNumber,
                                                                             completion: completion)
    }
    
    func deleteCurrentUserPhone(accessToken: String,
                                phoneNumber: String,
                                completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        DeleteCurrentUserPhoneAPIProxy(configuration).deleteCurrentUserPhone(accessToken: accessToken,
                                                                             phoneNumber: phoneNumber,
                                                                             completion: completion)
    }
    
    // MARK: User Account: User Friends
    
    func getCurrentUserFriends(accessToken: String,
                               listType: String,
                               sortType: String,
                               sortOrder: String,
                               after: String?,
                               limit: Int?,
                               completion: @escaping (LoginAPIResult<GetCurrentUserFriendsResponse>) -> Void)
    {
        GetCurrentUserFriendsAPIProxy(configuration).getCurrentUserFriends(accessToken: accessToken,
                                                                           listType: listType,
                                                                           sortType: sortType,
                                                                           sortOrder: sortOrder,
                                                                           after: after,
                                                                           limit: limit,
                                                                           completion: completion)
    }
    
    func updateCurrentUserFriends(accessToken: String,
                                  action: String,
                                  userID: String,
                                  completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        UpdateCurrentUserFriendsAPIProxy(configuration).updateCurrentUserFriends(accessToken: accessToken,
                                                                                 action: action,
                                                                                 userID: userID,
                                                                                 completion: completion)
    }
    
    // MARK: User Account: Social Networks

    func getLinksForSocialAuth(accessToken: String,
                               locale: String?,
                               completion: @escaping (LoginAPIResult<GetLinksForSocialAuthResponse>) -> Void)
    {
        GetLinksForSocialAuthAPIProxy(configuration).getLinksForSocialAuth(accessToken: accessToken,
                                                                           locale: locale,
                                                                           completion: completion)
    }

    func getLinkedNetworks(accessToken: String,
                           completion: @escaping (LoginAPIResult<GetLinkedNetworksResponse>) -> Void)
    {
        GetLinkedNetworksAPIProxy(configuration).getLinkedNetworks(accessToken: accessToken, completion: completion)
    }
    
    func getURLToLinkSocialNetworkToAccount(
        accessToken: String,
        providerName: String,
        loginURL: String,
        completion: @escaping (LoginAPIResult<GetURLToLinkSocialNetworkToAccountResponse>) -> Void)
    {
        GetURLToLinkSocialNetworkToAccountAPIProxy(configuration)
            .getURLToLinkSocialNetworkToAccount(accessToken: accessToken,
                                                providerName: providerName,
                                                loginURL: loginURL,
                                                completion: completion)
    }
    
    func getSocialNetworkFriends(accessToken: String,
                                 platform: String,
                                 offset: Int,
                                 limit: Int,
                                 withLoginId: Bool,
                                 completion: @escaping (LoginAPIResult<GetSocialNetworkFriendsResponse>) -> Void)
    {
        GetSocialNetworkFriendsAPIProxy(configuration).getSocialNetworkFriends(accessToken: accessToken,
                                                                               platform: platform,
                                                                               offset: offset,
                                                                               limit: limit,
                                                                               withLoginId: withLoginId,
                                                                               completion: completion)
    }
    
    func updateSocialNetworkFriends(accessToken: String,
                                    platform: String,
                                    completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        UpdateSocialNetworkFriendsAPIProxy(configuration).updateSocialNetworkFriends(accessToken: accessToken,
                                                                                     platform: platform,
                                                                                     completion: completion)
    }

    func searchUsersByNickname(nickname: String,
                               accessToken: String,
                               offset: Int?,
                               limit: Int?,
                               completion: @escaping (LoginAPIResult<SearchUsersByNicknameResponse>) -> Void)
    {
        SearchUsersByNicknameAPIProxy(configuration).searchUsersByNickname(nickname: nickname,
                                                                           accessToken: accessToken,
                                                                           offset: offset,
                                                                           limit: limit,
                                                                           completion: completion)
    }
    
    // MARK: - User Attributes
    
    func getClientUserAttributes(accessToken: String,
                                 keys: [String]?,
                                 publisherProjectId: Int?,
                                 userId: String?,
                                 completion: @escaping (LoginAPIResult<GetClientUserAttributesResponse>) -> Void)
    {
        GetClientUserAttributesAPIProxy(configuration).getClientUserAttributes(accessToken: accessToken,
                                                                               keys: keys,
                                                                               publisherProjectId: publisherProjectId,
                                                                               userId: userId,
                                                                               completion: completion)
    }
    
    func getClientUserReadOnlyAttributes(accessToken: String,
                                         keys: [String]?,
                                         publisherProjectId: Int?,
                                         userId: String?,
                                         completion: @escaping (LoginAPIResult<GetClientUserReadOnlyAttributesResponse>) -> Void)
    {
        GetClientUserReadOnlyAttributesAPIProxy(configuration)
            .getClientUserReadOnlyAttributes(accessToken: accessToken,
                                             keys: keys,
                                             publisherProjectId: publisherProjectId,
                                             userId: userId,
                                             completion: completion)
    }
    
    func updateClientUserAttributes(accessToken: String,
                                    attributes: [UpdateClientUserAttributesRequest.Body.Attribute]?,
                                    publisherProjectId: Int?,
                                    removingKeys: [String]?,
                                    completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        UpdateClientUserAttributesAPIProxy(configuration)
            .updateClientUserAttributes(accessToken: accessToken,
                                        attributes: attributes,
                                        publisherProjectId: publisherProjectId,
                                        removingKeys: removingKeys,
                                        completion: completion)
    }

    func checkUserAge(birthday: String,
                      accessToken: String,
                      loginId: String,
                      completion: @escaping (LoginAPIResult<Bool>) -> Void)
    {
        CheckUserAgeAPIProxy(configuration).checkUserAge(birthday: birthday,
                                                         accessToken: accessToken,
                                                         loginId: loginId,
                                                         completion: completion)
    }
}

extension LoginAPI
{
    var configuration: LoginAPIConfiguration
    {
        LoginAPIConfiguration(requestPerformer: requestPerformer,
                              responseProcessor: responseProcessor,
                              apiBasePath: "https://login.xsolla.com/api")
    }
}
