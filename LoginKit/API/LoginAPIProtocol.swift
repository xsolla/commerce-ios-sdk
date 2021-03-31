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

typealias LoginAPIError = Error
typealias LoginAPIResult<T> = Result<T, LoginAPIError>

protocol LoginAPIProtocol
{
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
    
    func getCurrentUserDetails(accessToken: String,
                               completion: @escaping (LoginAPIResult<GetCurrentUserDetailsResponse>) -> Void)
}
