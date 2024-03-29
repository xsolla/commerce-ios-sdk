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

/**
 Set of parameters to generate a JWT on the back-end side.
 */
public struct JWTGenerationParams
{
    /**
     The type of getting the JWT. Can have the following values:
     * `authorization_code` to exchange the code received in the [method](https://developers.xsolla.com/login-api/methods/oauth-20/oauth-20-auth-by-username-and-password/) to a JWT.
     The value of the `authCode` parameter must be specified.
     * `refresh_token` to get the refreshed JWT when the previous value is expired. The value of the `refreshToken` parameter must be specified.
     * `client_credentials` to get the server JWT without user participation, the values of the `clientId` and `clientSecret` parameters must be specified.
     */
    public let grantType: TokenGrantType

    /**
     Your application ID from [Publisher Account](https://publisher.xsolla.com/).
     You will get it after sending the request to enable the OAuth 2.0 protocol.
     */
    public let clientId: Int

    /**
     The `refreshToken` value received in the response to the last call of this method. **Required** if `grant_type=refresh_token`.
     */
    public let refreshToken: String?

    /**
     Your secret key hashed according to the [bcrypt](https://en.wikipedia.org/wiki/Bcrypt) algorithm.
     You got it after sending the request to enable OAuth 2.0. To get your secret key again, contact your Account Manager.
     */
    public let clientSecret: String?

    /**
     URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation.
     To set up this parameter, contact your Account Manager.
     */
    public let redirectUri: String?

    public init(grantType: TokenGrantType = .authorizationCode,
                clientId: Int,
                refreshToken: String? = nil,
                clientSecret: String? = nil,
                redirectUri: String? = nil)
    {
        self.grantType = grantType
        self.clientId = clientId
        self.refreshToken = refreshToken
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
    }
}
