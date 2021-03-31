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

/// Set of parameters to perform authentication with the OAuth2 protocol.
public struct OAuth2Params
{
    /// Your application ID from [Publisher Account](https://publisher.xsolla.com/).
    public let clientId: Int

    /// Value used for additional user verification. Often used to mitigate [CSRF Attacks](https://en.wikipedia.org/wiki/Cross-site_request_forgery).
    /// The value will be returned in the response. Must be longer than 8 characters.
    public let state: String

    /// Grant type used in your project that has the enabled OAuth 2.0 protocol. Must be **code** to get the user authentication code in the response.
    /// The received code must be exchanged to a JWT via the [Generate JWT](https://developers.xsolla.com/login-api/oauth-20/generate-jwt)
    /// method to finish user authentication.
    public let responseType: String

    /// Scope is a mechanism in OAuth 2.0 to limit application's access to a user's account.
    ///     Can be:
    ///         1. **email** for [Auth via social network](https://developers.xsolla.com/login-api/oauth-20/oauth-20-auth-via-social-network)
    ///         or [Get link for social auth](https://developers.xsolla.com/login-api/oauth-20/oauth-20-get-link-for-social-auth)
    ///         methods to additionally request an email from the user.
    ///         2. **offline** to use `refresh_token` from [Generate JWT](https://developers.xsolla.com/login-api/oauth-20/generate-jwt)
    ///         method to refresh the JWT when it is expired.
    ///         3. **playfab** to write SessionTicket to the session_ticket claim of the JWT if you store user data on the PlayFab side.
    ///         If you process your own values of the **scope** parameter, and the values aren't mentioned above, you can set them when using this method.
    public let scope: String?

    /// URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation.
    /// To set up this parameter, contact your Account Manager.
    public let redirectUri: String?

    public init(clientId: Int, state: String, scope: String?, redirectUri: String?)
    {
        self.clientId = clientId
        self.state = state
        self.responseType = "code"
        self.scope = scope
        self.redirectUri = redirectUri
    }
}
