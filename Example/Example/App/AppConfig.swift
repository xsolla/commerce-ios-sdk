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
import XsollaSDKStoreKit

enum AppConfig
{
    /// Application ID from [Publisher Account](https://publisher.xsolla.com/).
    /// You will get it after sending the request to enable the OAuth 2.0 protocol.
    static let loginClientId: Int = 57

    /// Project ID.
    static let projectId: Int = 58917

    /// Login project ID from [Publisher Account](https://publisher.xsolla.com/).
    static let loginProjectID: String = "026201e3-7e40-11ea-a85b-42010aa80004"

    static let defaultLoginScope: String = "offline"

    /// URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation.
    /// To set up this parameter, contact your Account Manager.
    static let redirectUrl: LoginRedirectUrlString = "https://login.xsolla.com/api/blank"

    /// URL to redirect the user to after receiving confirmation code for passwordless authentication.
    static let confirmationLink: String = "https://login-widget.xsolla.com/latest/confirm-status"

    /// URL to redirect to after successful payment. You can set it up in the **Pay Station > Settings > Redirect policy** section of your [Publisher Account](https://publisher.xsolla.com/).
    static let paymentsRedirectURL: String = "app://xsollaconfirm"

    static let demoUsername = "xsolla"
    static let demoPassword = "xsolla"

    static let paystationUITheme = StorePaymentProjectSettings.UISettings.Theme.defaultDark
}

extension AppConfig
{
    static var socialNetworkList: [SocialNetwork] =
    [
        .facebook,
        .linkedin,
        .discord,
        .twitter,
        .twitch,
        .reddit,
        .naver,
        .apple,
        .google,
        .yandex,
        .amazon,
        .baidu,
        .battlenet,
        .github,
        .kakao,
        .mailru,
        .microsoft,
        .msn,
        .ok,
        .paypal,
        .qq,
        .steam,
        .vimeo,
        .vk,
        .wechat,
        .weibo,
        .yahoo,
        .youtube,
        .xbox
    ]
}
