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

extension LoginAsyncUtility: LoginAsyncUtilityAuthProtocol
{
    func authWith(username: String, password: String) -> Promise<AccessTokenInfo>
    {
        let api = self.api
        let oAuth2Params = self.oAuth2Params
        let jwtParams = self.jwtParams

        return Promise<AccessTokenInfo>
        { fulfill, reject in

            api.authByUsernameAndPassword(username: username,
                                          password: password,
                                          oAuth2Params: oAuth2Params,
                                          jwtParams: jwtParams)
            { result in

                switch result
                {
                    case .success(let tokenInfo): fulfill(tokenInfo)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func authWith(deviceId: String, device: String) -> Promise<AccessTokenInfo>
    {
        let api = self.api
        let oAuth2Params = self.oAuth2Params
        let jwtParams = self.jwtParams

        return Promise<AccessTokenInfo>
        { fulfill, reject in

            api.authWithDeviceId(deviceId: deviceId, device: device, oAuth2Params: oAuth2Params, jwtParams: jwtParams)
            { result in

                switch result
                {
                    case .success(let redirectUrl): fulfill(redirectUrl)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func generateJWTWithAuthCode(_ authCode: LoginAuthCode) -> Promise<AccessTokenInfo>
    {
        generateJWTWith(authCode: authCode)
    }

    func generateJWTWith(authCode: LoginAuthCode) -> Promise<AccessTokenInfo>
    {
        let api = self.api
        let clientId = jwtParams.clientId
        let redirectURL = jwtParams.redirectUri

        return Promise<AccessTokenInfo>
        { fulfill, reject in

            let jwtParams = JWTGenerationParams(clientId: clientId, redirectUri: redirectURL)

            api.generateJWT(with: authCode, jwtParams: jwtParams)
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

            api.resetPassword(loginProjectId: AppConfig.loginId,
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
