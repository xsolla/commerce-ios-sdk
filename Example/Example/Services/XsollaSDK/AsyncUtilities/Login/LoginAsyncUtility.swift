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

class LoginAsyncUtility: LoginAsyncUtilityProtocol
{
    let api: XsollaSDKProtocol
    var clientId: Int { AppConfig.oAuth2ClientId }
    var redirectURL: String { AppConfig.redirectUrl }
    var scope: String { AppConfig.defaultLoginScope }

    var oAuth2Params: OAuth2Params
    {
        OAuth2Params(clientId: self.clientId,
                     state: UUID().uuidString,
                     scope: self.scope,
                     redirectUri: AppConfig.redirectUrl)
    }

    var jwtParams: JWTGenerationParams
    {
        JWTGenerationParams(clientId: self.clientId, redirectUri: self.redirectURL)
    }
    
    init(api: XsollaSDKProtocol)
    {
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
        self.api = api
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}
