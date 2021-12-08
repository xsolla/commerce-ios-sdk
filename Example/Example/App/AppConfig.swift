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

private enum AppConfigDefaults
{
    /// Application ID from [Publisher Account](https://publisher.xsolla.com/).
    /// You will get it after sending the request to enable the OAuth 2.0 protocol.
    static let oAuth2ClientId: Int = 57

    /// Project ID.
    static let projectId: Int = 77640

    /// Login ID from [Publisher Account](https://publisher.xsolla.com/).
    static let loginId: String = "026201e3-7e40-11ea-a85b-42010aa80004"

    /// URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation.
    /// To set up this parameter, contact your Account Manager.
    static let redirectUrl: RedirectUrlString = "https://login.xsolla.com/api/blank"

    /// Callback URL to redirect the user to the application during Apple Web Authorization Session (e.g., `app://xsollalogin`). You can set it up in [Publisher Account](https://publisher.xsolla.com/) in the **your Login project > General settings > Authorization > OAuth 2.0 authentication > OAuth 2.0 redirect URIs** field.
    static let customSchemeRedirectUrl: RedirectUrlString = "app://xsollalogin"

    /// URL to redirect the user to after receiving the confirmation code for passwordless authentication.
    static let passwordlessConfirmationUrl: RedirectUrlString = "https://login-widget.xsolla.com/latest/confirm-status"

    /// URL to redirect the user to after successful payment. You can set it up in [Publisher Account](https://publisher.xsolla.com/) in the **Pay Station > Settings > Redirect policy > Redirect URL** field.
    static let paymentsRedirectUrl: RedirectUrlString = "xsollasdk123456://xsollaconfirm/payment"

    /// Web shop URL.
    static let webshopUrl: String = "https://sitebuilder.xsolla.com/game/sdk-web-store/"
}

enum AppConfig
{
    /// Application ID from [Publisher Account](https://publisher.xsolla.com/).
    /// You will get it after sending the request to enable the OAuth 2.0 protocol.
    static var oAuth2ClientId: Int
    {
        AppConfigStore.getIntegerValue(forKey: .oAuth2ClientId) ?? AppConfigDefaults.oAuth2ClientId
    }

    /// Project ID.
    static var projectId: Int
    {
        AppConfigStore.getIntegerValue(forKey: .projectId) ?? AppConfigDefaults.projectId
    }

    /// Login ID from [Publisher Account](https://publisher.xsolla.com/).
    static var loginId: String
    {
        AppConfigStore.getStringValue(forKey: .loginId) ?? AppConfigDefaults.loginId
    }

    static let defaultLoginScope: String = "offline"

    /// URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation.
    /// To set up this parameter, contact your Account Manager.
    static var redirectUrl: RedirectUrlString
    {
        AppConfigStore.getStringValue(forKey: .redirectUrl) ?? AppConfigDefaults.redirectUrl
    }

    /// Callback URL to redirect the user to the application during Apple Web Authorization Session (e.g., `app://xsollalogin`). You can set it up in [Publisher Account](https://publisher.xsolla.com/) in the **your Login project > General settings > Authorization > OAuth 2.0 authentication > OAuth 2.0 redirect URIs** field.
    static var customSchemeRedirectUrl: RedirectUrlString
    {
        AppConfigStore.getStringValue(forKey: .customSchemeRedirectUrl) ?? AppConfigDefaults.customSchemeRedirectUrl
    }

    /// URL to redirect the user to after receiving the confirmation code for passwordless authentication.
    static var passwordlessConfirmationUrl: RedirectUrlString
    {
        AppConfigStore.getStringValue(forKey: .passwordlessConfirmationUrl) ??
            AppConfigDefaults.passwordlessConfirmationUrl
    }

    /// URL to redirect the user to after successful payment. You can set it up in the **Pay Station > Settings > Redirect policy** section of your [Publisher Account](https://publisher.xsolla.com/).
    static var paymentsRedirectURL: RedirectUrlString
    {
        AppConfigStore.getStringValue(forKey: .paymentsRedirectUrl) ?? AppConfigDefaults.paymentsRedirectUrl
    }

    /// Web shop URL.
    static var webshopUrl: String
    {
        AppConfigStore.getStringValue(forKey: .webshopUrl) ?? AppConfigDefaults.webshopUrl
    }

    static let demoUsername = "xsolla"
    static let demoPassword = "xsolla"

    static let paystationUITheme = StorePaymentProjectSettings.UISettings.Theme.ps4DefaultDark
    static let paystationUISize = StorePaymentProjectSettings.UISettings.Size.medium

    /// Defines where Pay Station should open: inside the app or in an external browser.
    static let useExternalBrowserForPayStation = true

    /// Whether to send the confirmation link via email in case of passwordless authentication.
    static let sendEmailOTPConfirmationLink = true
    /// Whether to send the confirmation link via an SMS in case of passwordless authentication.
    static let sendPhoneOTPConfirmationLink = false
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

extension AppConfig
{
    static func setOAuth2ClientId(_ value: Int?)
    {
        AppConfigStore.setIntegerValue(value, forKey: .oAuth2ClientId)
    }

    static func setProjectId(_ value: Int?)
    {
        AppConfigStore.setIntegerValue(value, forKey: .projectId)
    }

    static func setLoginId(_ value: String?)
    {
        AppConfigStore.setStringValue(value, forKey: .loginId)
    }

    static func setRedirectUrl(_ value: String?)
    {
        AppConfigStore.setStringValue(value, forKey: .redirectUrl)
    }

    static func setCustomSchemeRedirectUrl(_ value: String?)
    {
        AppConfigStore.setStringValue(value, forKey: .customSchemeRedirectUrl)
    }

    static func setConfirmationLink(_ value: String?)
    {
        AppConfigStore.setStringValue(value, forKey: .passwordlessConfirmationUrl)
    }

    static func setPaymentsRedirectURL(_ value: String?)
    {
        AppConfigStore.setStringValue(value, forKey: .paymentsRedirectUrl)
    }

    static func setWebshopUrl(_ value: String?)
    {
        AppConfigStore.setStringValue(value, forKey: .webshopUrl)
    }

    static func resetToDefaults()
    {
        AppConfigStore.setStringValue(nil, forKey: .oAuth2ClientId)
        AppConfigStore.setStringValue(nil, forKey: .projectId)
        AppConfigStore.setStringValue(nil, forKey: .loginId)
        AppConfigStore.setStringValue(nil, forKey: .redirectUrl)
        AppConfigStore.setStringValue(nil, forKey: .customSchemeRedirectUrl)
        AppConfigStore.setStringValue(nil, forKey: .passwordlessConfirmationUrl)
        AppConfigStore.setStringValue(nil, forKey: .paymentsRedirectUrl)
        AppConfigStore.setStringValue(nil, forKey: .webshopUrl)
    }
}

private enum AppConfigStore
{
    static func getStringValue(forKey key: Key) -> String?
    {
        UserDefaults.standard.string(forKey: key.rawValue)
    }

    static func getIntegerValue(forKey key: Key) -> Int?
    {
        UserDefaults.standard.value(forKey: key.rawValue) as? Int
    }

    static func setStringValue(_ value: String?, forKey key: Key)
    {
        guard let value = value else
        {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
            return
        }

        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func setIntegerValue(_ value: Int?, forKey key: Key)
    {
        guard let value = value else
        {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
            return
        }

        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    enum Key: String
    {
        case oAuth2ClientId
        case projectId
        case loginId
        case redirectUrl
        case customSchemeRedirectUrl
        case passwordlessConfirmationUrl
        case paymentsRedirectUrl
        case webshopUrl
    }
}
