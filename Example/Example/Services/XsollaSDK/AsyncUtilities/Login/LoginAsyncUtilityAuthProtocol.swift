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
// swiftlint:disable line_length

protocol LoginAsyncUtilityAuthProtocol: AsyncUtilityProtocol
{
    func authWith(username: String, password: String, clientId: Int?, scope: String?) -> Promise<AccessTokenInfo>

    func authWith(deviceId: String, device: String, state: String?, clientId: Int?, redirectUri: String?, scope: String?, responseType: String?) -> Promise<AccessTokenInfo>

    func generateJWTWith(authCode: String, clientId: Int?, clientSecret: String?, redirectURL: String?, refreshToken: RefreshToken?) -> Promise<AccessTokenInfo>

    func extractAuthCode(redirectUrl url: LoginRedirectUrlString) -> Promise<LoginAuthCode>

    func resetPassword(username: String) -> Promise<Void>

    func getRedirectUrlParsingError(redirectUrl url: LoginRedirectUrlString) -> Error?
}

extension LoginAsyncUtilityAuthProtocol
{
    func authWith(username: String, password: String, clientId: Int? = nil, scope: String? = nil) -> Promise<AccessTokenInfo>
    {
        authWith(username: username, password: password, clientId: clientId, scope: scope)
    }

    func authWith(deviceId: String, device: String, state: String? = nil, clientId: Int? = nil, redirectUri: String? = nil, scope: String? = nil, responseType: String? = nil) -> Promise<AccessTokenInfo>
    {
        authWith(deviceId: deviceId, device: device, state: state, clientId: clientId, redirectUri: redirectUri, scope: scope, responseType: responseType)
    }

    func generateJWTWith(authCode: String, clientId: Int? = nil, clientSecret: String? = nil, redirectURL: String? = nil, refreshToken: RefreshToken? = nil) -> Promise<AccessTokenInfo>
    {
        generateJWTWith(authCode: authCode, clientId: clientId, clientSecret: clientSecret, redirectURL: redirectURL, refreshToken: refreshToken)
    }
}
