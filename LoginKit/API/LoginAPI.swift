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
    
    func authByUsernameAndPasswordJWT(
        username: String,
        password: String,
        clientId: Int,
        scope: String?,
        completion: @escaping (LoginAPIResult<AuthByUsernameAndPasswordJWTResponse>) -> Void)
    {
        AuthByUsernameAndPasswordJWTAPIProxy(configuration).authByUsernameAndPassword(username: username,
                                                                                      password: password,
                                                                                      clientId: clientId,
                                                                                      scope: scope,
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
    
    func generateJWT(grantType: String,
                     clientId: Int,
                     refreshToken: String?,
                     clientSecret: String?,
                     redirectUri: String?,
                     authCode: String?,
                     completion: @escaping (LoginAPIResult<GenerateJWTResponse>) -> Void)
    {
        GenerateJWTAPIProxy(configuration).generateJWT(grantType: grantType,
                                                       clientId: clientId,
                                                       refreshToken: refreshToken,
                                                       clientSecret: clientSecret,
                                                       redirectUri: redirectUri,
                                                       authCode: authCode,
                                                       completion: completion)
    }
    
    func registerNewUser(oAuth2Params: OAuth2Params,
                         username: String,
                         password: String,
                         email: String,
                         acceptConsent: Bool?,
                         fields: [String: String]?,
                         promoEmailAgreement: Int?,
                         completion: @escaping (LoginAPIResult<RegisterNewUserResponse>) -> Void)
    {
        RegisterNewUserAPIProxy(configuration).registerNewUser(oAuth2Params: oAuth2Params,
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
                       completion: @escaping (LoginAPIResult<APIEmptyResponse>) -> Void)
    {
        ResetPasswordAPIProxy(configuration).resetPassword(loginProjectId: loginProjectId,
                                                           username: username,
                                                           loginUrl: loginUrl,
                                                           completion: completion)
    }
    
    func getCurrentUserDetails(accessToken: String,
                               completion: @escaping (LoginAPIResult<GetCurrentUserDetailsResponse>) -> Void)
    {
        GetCurrentUserDetailsAPIProxy(configuration).getCurrentUserDetails(accessToken: accessToken,
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
