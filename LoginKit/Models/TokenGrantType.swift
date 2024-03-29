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

/// The type of getting the JWT.
public enum TokenGrantType: String
{
    /// To exchange the code received in the [method](https://developers.xsolla.com/login-api/methods/oauth-20/oauth-20-auth-by-username-and-password/)
    /// for a JWT.
    case authorizationCode = "authorization_code"

    /// To get the refreshed JWT when the previous value is expired.
    case refreshToken = "refresh_token"

    /// To get the server JWT without user participation.
    case clientCredentials = "client_credentials"
}
