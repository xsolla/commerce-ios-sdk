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
    let apiBasePath: String
    let requestPerformer: RequestPerformer
    let responseProcessor: ResponseProcessor
    
    init(apiBasePath: String, requestPerformer: RequestPerformer, responseProcessor: ResponseProcessor)
    {
        logger.debug(.initialization, domain: .loginKit) { String(describing: Self.self) }
        
        self.apiBasePath = apiBasePath
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
        let params = LogUserOutRequest.Params(accessToken: accessToken, sessionType: sessionType)
        let request = LogUserOutRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in

            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func authByUsernameAndPassword(username: String,
                                   password: String,
                                   oAuth2Params: OAuth2Params,
                                   completion: @escaping (LoginAPIResult<AuthByUsernameAndPasswordResponse>) -> Void)
    {
        let params = AuthByUsernameAndPasswordRequest.Params(username: username,
                                                             password: password,
                                                             responseType: oAuth2Params.responseType,
                                                             clientId: oAuth2Params.clientId,
                                                             state: oAuth2Params.state,
                                                             scope: oAuth2Params.scope,
                                                             redirectUri: oAuth2Params.redirectUri)

        let request = AuthByUsernameAndPasswordRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getLinkForSocialAuth(providerName: String,
                              clientId: Int,
                              state: String,
                              responseType: String,
                              scope: String?,
                              redirectUri: String?,
                              completion: @escaping (LoginAPIResult<GetLinkForSocialAuthResponse>) -> Void)
    {
        let params = GetLinkForSocialAuthRequest.Params(providerName: providerName,
                                                        clientId: clientId,
                                                        state: state,
                                                        responseType: responseType,
                                                        scope: scope,
                                                        redirectUri: redirectUri)

        let request = GetLinkForSocialAuthRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func authBySocialNetwork(oAuth2Params: OAuth2Params,
                             providerName: String,
                             socialNetworkAccessToken: String,
                             socialNetworkAccessTokenSecret: String?,
                             socialNetworkOpenId: String?,
                             completion: @escaping (LoginAPIResult<AuthBySocialNetworkResponse>) -> Void)
    {
        let params = AuthBySocialNetworkRequest.Params(
            providerName: providerName,
            clientId: oAuth2Params.clientId,
            responseType: oAuth2Params.responseType,
            state: oAuth2Params.state,
            redirectUri: oAuth2Params.redirectUri,
            scope: oAuth2Params.scope,
            socialNetworkAccessToken: socialNetworkAccessToken,
            socialNetworkAccessTokenSecret: socialNetworkAccessTokenSecret,
            socialNetworkOpenId: socialNetworkOpenId)

        let request = AuthBySocialNetworkRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func deleteLinkedNetwork(accessToken: String,
                             providerName: String,
                             completion: @escaping (LoginAPIResult<Void>) -> Void)
    {
        let params =  DeleteLinkedNetworkRequest.Params(accessToken: accessToken, providerName: providerName)

        let request = DeleteLinkedNetworkRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
            }
        }

    }

    func generateJWT(with authCode: String?,
                     jwtParams: JWTGenerationParams,
                     completion: @escaping (LoginAPIResult<GenerateJWTResponse>) -> Void)
    {
        let params = GenerateJWTRequest.Params(grantType: jwtParams.grantType.rawValue,
                                               clientId: jwtParams.clientId,
                                               refreshToken: jwtParams.refreshToken,
                                               clientSecret: jwtParams.clientSecret,
                                               redirectUri: jwtParams.redirectUri,
                                               authCode: authCode)

        let request = GenerateJWTRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func registerNewUser(params: RegisterNewUserParams,
                         oAuth2Params: OAuth2Params,
                         locale: String?,
                         completion: @escaping (LoginAPIResult<RegisterNewUserResponse>) -> Void)
    {
        let bodyParams = RegisterNewUserRequest.Params.BodyParams(username: params.username,
                                                                  password: params.password,
                                                                  email: params.email,
                                                                  acceptConsent: params.acceptConsent,
                                                                  fields: params.fields,
                                                                  promoEmailAgreement: params.promoEmailAgreement)

        let params = RegisterNewUserRequest.Params(responseType: oAuth2Params.responseType,
                                                   clientId: oAuth2Params.clientId,
                                                   locale: locale,
                                                   state: oAuth2Params.state,
                                                   scope: oAuth2Params.scope,
                                                   redirectUri: oAuth2Params.redirectUri,
                                                   bodyParams: bodyParams)

        let request = RegisterNewUserRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func resetPassword(loginProjectId: String,
                       username: String,
                       loginUrl: String?,
                       locale: String?,
                       completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = ResetPasswordRequest.Params(loginProjectId: loginProjectId, username: username, loginUrl: loginUrl, locale: locale)
        let request = ResetPasswordRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func startAuthByEmail(oAuth2Params: OAuth2Params,
                          email: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          locale: String? = nil,
                          completion: @escaping (LoginAPIResult<StartAuthByEmailResponse>) -> Void)
    {
        let params = StartAuthByEmailRequest.Params(responseType: oAuth2Params.responseType,
                                                    clientId: oAuth2Params.clientId,
                                                    scope: oAuth2Params.scope,
                                                    state: oAuth2Params.state,
                                                    redirectUri: oAuth2Params.redirectUri,
                                                    email: email,
                                                    linkUrl: linkUrl,
                                                    sendLink: sendLink,
                                                    locale: locale)

        let request = StartAuthByEmailRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func completeAuthByEmail(clientId: Int,
                             code: String,
                             email: String,
                             operationId: String,
                             completion: @escaping (LoginAPIResult<CompleteAuthByEmailResponse>) -> Void)
    {
        let params = CompleteAuthByEmailRequest.Params(clientId: clientId,
                                                       code: code,
                                                       email: email,
                                                       operationId: operationId)

        let request = CompleteAuthByEmailRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func startAuthByPhone(oAuth2Params: OAuth2Params,
                          phoneNumber: String,
                          linkUrl: String?,
                          sendLink: Bool,
                          completion: @escaping (LoginAPIResult<StartAuthByPhoneResponse>) -> Void)
    {
        let params = StartAuthByPhoneRequest.Params(responseType: oAuth2Params.responseType,
                                                    clientId: oAuth2Params.clientId,
                                                    scope: oAuth2Params.scope,
                                                    state: oAuth2Params.state,
                                                    redirectUri: oAuth2Params.redirectUri,
                                                    phoneNumber: phoneNumber,
                                                    linkUrl: linkUrl,
                                                    sendLink: sendLink)

        let request = StartAuthByPhoneRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func completeAuthByPhone(clientId: Int,
                             code: String,
                             operationId: String,
                             phoneNumber: String,
                             completion: @escaping (LoginAPIResult<CompleteAuthByPhoneResponse>) -> Void)
    {
        let params = CompleteAuthByPhoneRequest.Params(clientId: clientId,
                                                       code: code,
                                                       operationId: operationId,
                                                       phoneNumber: phoneNumber)

        let request = CompleteAuthByPhoneRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func getConfirmationCode(projectId: String,
                             login: String,
                             operationId: String,
                             completion: @escaping (LoginAPIResult<String>) -> Void)
    {
        let params = GetConfirmationCodeRequest.Params(projectId: projectId,
                                                       login: login,
                                                       operationId: operationId)

        let request = GetConfirmationCodeRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in

            switch result
            {
                case .success(let model): completion(.success(model.code))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func resendConfirmationLink(clientId: Int,
                                redirectUri: String,
                                state: String,
                                username: String,
                                locale: String?,
                                completion: @escaping (LoginAPIResult<Void>) -> Void)
    {
        let params = ResendConfirmationLinkRequest.Params(clientId: clientId,
                                                          redirectUri: redirectUri,
                                                          state: state,
                                                          username: username,
                                                          locale: locale)

        let request = ResendConfirmationLinkRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in

            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func authWithDeviceId(oAuth2Params: OAuth2Params,
                          device: String,
                          deviceId: String,
                          completion: @escaping (LoginAPIResult<AuthWithDeviceIdResponse>) -> Void)
    {
        let params = AuthWithDeviceIdRequest.Params(responseType: oAuth2Params.responseType,
                                                    clientId: oAuth2Params.clientId,
                                                    scope: oAuth2Params.scope,
                                                    state: oAuth2Params.state,
                                                    redirectUri: oAuth2Params.redirectUri,
                                                    device: device,
                                                    deviceId: deviceId)

        let request = AuthWithDeviceIdRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getUserDevices(accessToken: String, completion: @escaping (LoginAPIResult<GetUserDevicesResponse>) -> Void)
    {
        let request = GetUserDevicesRequest(params: .init(accessToken: accessToken), apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func linkDeviceToAccount(device: String,
                             deviceId: String,
                             accessToken: String,
                             completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = LinkDeviceToAccountRequest.Params(device: device, deviceId: deviceId, accessToken: accessToken)

        let request = LinkDeviceToAccountRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func unlinkDeviceFromAccount(deviceId: String,
                                 accessToken: String,
                                 completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = UnlinkDeviceFromAccountRequest.Params(deviceId: deviceId, accessToken: accessToken)

        let request = UnlinkDeviceFromAccountRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func addUsernameAndPassword(accessToken: String,
                                username: String,
                                password: String,
                                email: String,
                                promoEmailAgreement: Bool,
                                redirectUri: String?,
                                completion: @escaping (LoginAPIResult<AddUsernameAndPasswordResponse>) -> Void)
    {
        let bodyParams = AddUsernameAndPasswordRequest.Body(username: username,
                                                            password: password,
                                                            email: email,
                                                            promoEmailAgreement: promoEmailAgreement ? 1 : 0)

        let params = AddUsernameAndPasswordRequest.Params(accessToken: accessToken,
                                                          redirectUri: redirectUri,
                                                          bodyParams: bodyParams)

        let request = AddUsernameAndPasswordRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func createCodeForLinkingAccounts(accessToken: String,
                                      completion: @escaping (LoginAPIResult<String>) -> Void)
    {
        let params = CreateCodeForLinkingAccountsRequest.Params(accessToken: accessToken)

        let request = CreateCodeForLinkingAccountsRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in

            switch result
            {
                case .success(let model): completion(.success(model.code))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    // MARK: - User Account API

    func getUserPublicProfile(userId: String,
                              accessToken: String,
                              completion: @escaping (LoginAPIResult<GetUserPublicProfileResponse>) -> Void)
    {
        let params = GetUserPublicProfileRequest.Params(accessToken: accessToken, userId: userId)

        let request = GetUserPublicProfileRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func getCurrentUserDetails(accessToken: String,
                               completion: @escaping (LoginAPIResult<GetCurrentUserDetailsResponse>) -> Void)
    {
        let request = GetCurrentUserDetailsRequest(params: .init(accessToken: accessToken),
                                                   apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func updateCurrentUserDetails(accessToken: String,
                                  birthday: String?,
                                  firstName: String?,
                                  lastName: String?,
                                  gender: String?,
                                  nickname: String?,
                                  completion: @escaping (LoginAPIResult<UpdateCurrentUserDetailsResponse>) -> Void)
    {
        let params = UpdateCurrentUserDetailsRequest.Params(accessToken: accessToken,
                                                            birthday: birthday,
                                                            firstName: firstName,
                                                            lastName: lastName,
                                                            gender: gender,
                                                            nickname: nickname)

        let request = UpdateCurrentUserDetailsRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getUserEmail(accessToken: String,
                      completion: @escaping (LoginAPIResult<GetUserEmailResponse>) -> Void)
    {
        let request = GetUserEmailRequest(params: .init(accessToken: accessToken),
                                          apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func deleteUserPicture(accessToken: String, completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let request = DeleteUserPictureRequest(params: .init(accessToken: accessToken),
                                               apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func uploadUserPicture(accessToken: String,
                           imageURL: URL,
                           completion: @escaping (LoginAPIResult<UploadUserPictureResponse>) -> Void)
    {
        let params = UploadUserPictureRequest.Params(accessToken: accessToken, imageURL: imageURL)

        let request = UploadUserPictureRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getCurrentUserPhone(accessToken: String,
                             completion: @escaping (LoginAPIResult<GetCurrentUserPhoneResponse>) -> Void)
    {
        let request = GetCurrentUserPhoneRequest(params: .init(accessToken: accessToken),
                                                 apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func updateCurrentUserPhone(accessToken: String,
                                phoneNumber: String,
                                completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = UpdateCurrentUserPhoneRequest.Params(accessToken: accessToken, phoneNumber: phoneNumber)
        let request = UpdateCurrentUserPhoneRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func deleteCurrentUserPhone(accessToken: String,
                                phoneNumber: String,
                                completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = DeleteCurrentUserPhoneRequest.Params(accessToken: accessToken, phoneNumber: phoneNumber)
        let request = DeleteCurrentUserPhoneRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
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
        let params = GetCurrentUserFriendsRequest.Params(accessToken: accessToken,
                                                         listType: listType,
                                                         sortType: sortType,
                                                         sortOrder: sortOrder,
                                                         after: after,
                                                         limit: limit)

        let request = GetCurrentUserFriendsRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func updateCurrentUserFriends(accessToken: String,
                                  action: String,
                                  userID: String,
                                  completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = UpdateCurrentUserFriendsRequest.Params(accessToken: accessToken,
                                                            action: action,
                                                            userID: userID)

        let request = UpdateCurrentUserFriendsRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    // MARK: User Account: Social Networks

    func getLinksForSocialAuth(accessToken: String,
                               locale: String?,
                               completion: @escaping (LoginAPIResult<GetLinksForSocialAuthResponse>) -> Void)
    {
        let params = GetLinksForSocialAuthRequest.Params(accessToken: accessToken, locale: locale)

        let request = GetLinksForSocialAuthRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func getLinkedNetworks(accessToken: String,
                           completion: @escaping (LoginAPIResult<GetLinkedNetworksResponse>) -> Void)
    {
        let params = GetLinkedNetworksRequest.Params(accessToken: accessToken)

        let request = GetLinkedNetworksRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getURLToLinkSocialNetworkToAccount(
        accessToken: String,
        providerName: String,
        loginURL: String,
        completion: @escaping (LoginAPIResult<GetURLToLinkSocialNetworkToAccountResponse>) -> Void)
    {
        let params = GetURLToLinkSocialNetworkToAccountRequest.Params(accessToken: accessToken,
                                                                      providerName: providerName,
                                                                      loginURL: loginURL)

        let request = GetURLToLinkSocialNetworkToAccountRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getSocialNetworkFriends(accessToken: String,
                                 platform: String,
                                 offset: Int,
                                 limit: Int,
                                 withLoginId: Bool,
                                 completion: @escaping (LoginAPIResult<GetSocialNetworkFriendsResponse>) -> Void)
    {
        let params = GetSocialNetworkFriendsRequest.Params(accessToken: accessToken,
                                                           platform: platform,
                                                           offset: offset,
                                                           limit: limit,
                                                           withLoginId: withLoginId)

        let request = GetSocialNetworkFriendsRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func updateSocialNetworkFriends(accessToken: String,
                                    platform: String,
                                    completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let params = UpdateSocialNetworkFriendsRequest.Params(accessToken: accessToken, platfrom: platform)
        let request = UpdateSocialNetworkFriendsRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func searchUsersByNickname(nickname: String,
                               accessToken: String,
                               offset: Int?,
                               limit: Int?,
                               completion: @escaping (LoginAPIResult<SearchUsersByNicknameResponse>) -> Void)
    {
        let params = SearchUsersByNicknameRequest.Params(nickname: nickname,
                                                         accessToken: accessToken,
                                                         offset: offset,
                                                         limit: limit)

        let request = SearchUsersByNicknameRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    // MARK: - User Attributes
    
    func getClientUserAttributes(accessToken: String,
                                 keys: [String]?,
                                 publisherProjectId: Int?,
                                 userId: String?,
                                 completion: @escaping (LoginAPIResult<GetClientUserAttributesResponse>) -> Void)
    {
        let bodyParams = GetClientUserAttributesRequest.Body(keys: keys,
                                                             publisherProjectId: publisherProjectId,
                                                             userId: userId)
        let params = GetClientUserAttributesRequest.Params(accessToken: accessToken, bodyParams: bodyParams)

        let request = GetClientUserAttributesRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getClientUserReadOnlyAttributes(accessToken: String,
                                         keys: [String]?,
                                         publisherProjectId: Int?,
                                         userId: String?,
                                         completion: @escaping (LoginAPIResult<GetClientUserReadOnlyAttributesResponse>) -> Void)
    {
        let bodyParams = GetClientUserReadOnlyAttributesRequest.Body(keys: keys,
                                                                     publisherProjectId: publisherProjectId,
                                                                     userId: userId)
        let params = GetClientUserReadOnlyAttributesRequest.Params(accessToken: accessToken, bodyParams: bodyParams)

        let request = GetClientUserReadOnlyAttributesRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func updateClientUserAttributes(accessToken: String,
                                    attributes: [UpdateClientUserAttributesRequest.Body.Attribute]?,
                                    publisherProjectId: Int?,
                                    removingKeys: [String]?,
                                    completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        let bodyParams = UpdateClientUserAttributesRequest.Body(attributes: attributes,
                                                                publisherProjectId: publisherProjectId,
                                                                removingKeys: removingKeys)
        let params = UpdateClientUserAttributesRequest.Params(accessToken: accessToken, bodyParams: bodyParams)

        let request = UpdateClientUserAttributesRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }

    func checkUserAge(birthday: String,
                      accessToken: String,
                      loginId: String,
                      completion: @escaping (LoginAPIResult<Bool>) -> Void)
    {
        let params = CheckUserAgeRequest.Params(birthday: birthday,
                                                accessToken: accessToken,
                                                loginId: loginId)

        let request = CheckUserAgeRequest(params: params, apiConfiguration: configuration)

        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel.accepted))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
}

extension LoginAPI
{
    var configuration: LoginAPIConfiguration
    {
        LoginAPIConfiguration(requestPerformer: requestPerformer,
                              responseProcessor: responseProcessor,
                              apiBasePath: apiBasePath)
    }
}
