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

import Foundation
import XsollaSDKLoginKit
import Promises

// swiftlint:disable function_parameter_count

extension LoginAsyncUtility: LoginAsyncUtilityAuthProtocol
{
    func authWith(username: String, password: String, clientId: Int?, scope: String?) -> Promise<AccessTokenInfo>
    {
        let api = self.api

        return Promise<AccessTokenInfo>
        { fulfill, reject in

            api.authByUsernameAndPasswordJWT(username: username,
                                             password: password,
                                             clientId: clientId ?? self.clientId,
                                             scope: scope ?? self.scope)
            { result in

                switch result
                {
                    case .success(let tokenInfo): fulfill(tokenInfo)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func authWith(deviceId: String,
                  device: String,
                  state: String?,
                  clientId: Int?,
                  redirectUri: String?,
                  scope: String?,
                  responseType: String?) -> Promise<AccessTokenInfo>
    {
        let oAuth2Params = OAuth2Params(clientId: clientId ?? self.clientId,
                                        state: state ?? UUID().uuidString,
                                        scope: scope ?? self.scope,
                                        redirectUri: redirectUri ?? self.redirectURL)

        return
            authWith(deviceId: deviceId, device: device, oAuth2Params: oAuth2Params)
            .then(extractAuthCode)
            .then(generateJWTWithAuthCode)
    }

    func authWith(deviceId: String, device: String, oAuth2Params: OAuth2Params) -> Promise<LoginRedirectUrlString>
    {
        let api = self.api

        return Promise<LoginRedirectUrlString>
        { fulfill, reject in

            api.authWithDeviceId(oAuth2Params: oAuth2Params, device: device, deviceId: deviceId)
            { result in

                switch result
                {
                    case .success(let redirectUrl): fulfill(redirectUrl)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func extractAuthCode(redirectUrl url: LoginRedirectUrlString) -> Promise<LoginAuthCode>
    {
        if
            let urlComponents = URLComponents(string: url),
            let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value
        {
            return Promise(code)
        }
        else
        {
            return Promise(getRedirectUrlParsingError(redirectUrl: url) ?? RedirectUrlParsingError.unknownError(nil))
        }
    }

    func getRedirectUrlParsingError(redirectUrl url: LoginRedirectUrlString) -> Error?
    {
        guard
            let urlComponents = URLComponents(string: url),
            let errorCode = urlComponents.queryItems?.first(where: { $0.name == "error_code" })?.value,
            var errorDescription = urlComponents.queryItems?.first(where: { $0.name == "error_description" })?.value
        else
            { return nil }

        errorDescription = errorDescription.replacingOccurrences(of: "+", with: " ")

        switch errorCode
        {
            case "010-016": return RedirectUrlParsingError.networkLinkingError(errorDescription)
            default: return RedirectUrlParsingError.unknownError(errorDescription)
        }
    }

    func generateJWTWithAuthCode(_ authCode: LoginAuthCode) -> Promise<AccessTokenInfo>
    {
        generateJWTWith(authCode: authCode)
    }

    func generateJWTWith(authCode: LoginAuthCode,
                         clientId: Int?,
                         clientSecret: String?,
                         redirectURL: String?,
                         refreshToken: RefreshToken?) -> Promise<AccessTokenInfo>
    {
        let api = self.api
        let clientId = clientId ?? self.clientId
        let redirectURL = redirectURL ?? self.redirectURL

        return Promise<AccessTokenInfo>
        { fulfill, reject in

            api.generateJWT(grantType: .authorizationCode,
                            clientId: clientId,
                            refreshToken: refreshToken,
                            clientSecret: clientSecret,
                            redirectUri: redirectURL,
                            authCode: authCode)
            { result in
                switch result
                {
                    case .success(let tokenInfo): fulfill(tokenInfo)
                    case .failure(let error): reject(error)
                }
            }
        }
    }
    
    func resetPassword(username: String) -> Promise<Void>
    {
        let api = self.api

        return Promise<Void>
        { fulfill, reject in

            api.resetPassword(loginProjectId: AppConfig.loginProjectID,
                              username: username,
                              loginUrl: AppConfig.redirectUrl)
            { result in

                switch result
                {
                    case .success: fulfill(())
                    case .failure(let error): reject(error)
                }
            }
        }
    }
}
