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

// swiftlint:disable nesting

import Foundation

/// Custom project settings.
public struct StorePaymentProjectSettings: Encodable
{
    /// Interface settings.
    public let ui: UISettings

    /// Payment method ID.
    public let paymentMethod: Int?

    /// Page to redirect the user to after payment. Parameters `user_id`, `foreigninvoice`, `invoice_id` and `status` will be automatically added to the link.
    public let returnUrl: String?

    /// Redirect policy rules and settings.
    public let redirectPolicy: RedirectPolicy?

    /// Transaction external id.
    public let externalId: String?
    
    /// Settings for generating a payment token for different platforms.
    private let sdk: SDKTokenSettings

    enum CodingKeys: String, CodingKey
    {
        case ui
        case paymentMethod = "payment_method"
        case returnUrl = "return_url"
        case redirectPolicy = "redirect_policy"
        case externalId = "external_id"
        case sdk
    }

    public init(ui: UISettings,
                paymentMethod: Int? = nil,
                returnUrl: String? = nil,
                redirectPolicy: RedirectPolicy? = nil,
                externalId: String? = nil)
    {
        self.ui = ui
        self.paymentMethod = paymentMethod
        self.returnUrl = returnUrl
        self.redirectPolicy = redirectPolicy
        self.externalId = externalId
        sdk = SDKTokenSettings()
    }
}

extension StorePaymentProjectSettings
{
    public struct SDKTokenSettings: Encodable
    {
        /// Application build platform.
        public let platform: String
        
        /// Type of browser used to launch payment UI.
        public let browserType: String

        enum CodingKeys: String, CodingKey
        {
            case platform
            case browserType = "browser_type"
        }
        
        public init()
        {
            self.platform = "ios"
            self.browserType = "wk_web_view"
        }
    }
}
extension StorePaymentProjectSettings
{
    public struct UISettings: Encodable
    {
        /// Payment UI theme.
        public let theme: String

        // Pay Station UI settings for the mobile version.
        public let mobilePlatformSettings: PlatformSettings?

        /// Payment UI size. Can be:
        /// - [small](https://livedemo.xsolla.com/developers/small/): the least possible size of the payment UI. Use this value when the window size is strictly limited (dimensions: 620 x 630).
        /// - [medium](https://livedemo.xsolla.com/developers/medium/): recommended size. Use this value to display the payment UI in a lightbox (dimensions: 740 x 760).
        /// - [large](https://livedemo.xsolla.com/developers/large/): the optimal size for displaying the payment UI in a new window or tab (dimensions: 820 x 840).\n
        public let size: Size?

        enum CodingKeys: String, CodingKey
        {
            case theme
            case mobilePlatformSettings = "mobile"
            case size
        }

        public init(theme: String, size: Size? = nil, mobilePlatformSettings: PlatformSettings?)
        {
            self.theme = theme
            self.size = size
            self.mobilePlatformSettings = mobilePlatformSettings
        }
    }
}

extension StorePaymentProjectSettings.UISettings
{
    public struct PlatformSettings: Encodable
    {
        /// Header settings.
        public let header: Header?

        public init(header: Header?)
        {
            self.header = header
        }
    }
}

extension StorePaymentProjectSettings.UISettings.PlatformSettings
{
    public struct Header: Encodable
    {
        /// Whether to show a button to close Pay Station.
        public let closeButton: Bool?
        
        /// The icon of the Close button in the payment UI. Can be `arrow` or `cross`.
        public let closeButtonIcon: String?

        enum CodingKeys: String, CodingKey
        {
            case closeButton = "close_button"
            case closeButtonIcon = "close_button_icon"
        }

        public init(closeButton: Bool?,
                    closeButtonIcon: String? = nil)
        {
            self.closeButton = closeButton
            self.closeButtonIcon = closeButtonIcon
        }
    }
}

extension StorePaymentProjectSettings.UISettings
{
    public enum Size: String, Encodable
    {
        case small
        case medium
        case large
    }
}

extension StorePaymentProjectSettings
{
    public struct RedirectPolicy: Encodable
    {
        /// Payment status triggering user redirect to the return URL.
        public let redirectConditions: RedirectConditions

        /// Delay after which the user will be automatically redirected to the return URL.
        public let delay: Int

        /// Payment status triggering the display of a button clicking which redirects the user to the return URL.
        public let statusForManualRedirection: StatusForManualRedirection

        /// Localized redirect button captions.
        public let redirectButtonCaption: String

        enum CodingKeys: String, CodingKey
        {
            case redirectConditions = "redirect_conditions"
            case delay = "delay"
            case statusForManualRedirection = "status_for_manual_redirection"
            case redirectButtonCaption = "redirect_button_caption"
        }

        public init(redirectConditions: RedirectConditions,
                    delay: Int,
                    statusForManualRedirection: StatusForManualRedirection,
                    redirectButtonCaption: String)
        {
            self.redirectConditions = redirectConditions
            self.delay = delay
            self.statusForManualRedirection = statusForManualRedirection
            self.redirectButtonCaption = redirectButtonCaption
        }

        public enum RedirectConditions: String, Codable
        {
            case none = "none"
            case successful = "successful"
            case successfulOrCanceled = "successful_or_canceled"
            case any = "any"
        }

        public enum StatusForManualRedirection: String, Codable
        {
            case none = "none"
            case vc = "vc"
            case successful = "successful"
            case successfulOrCanceled = "successful_or_canceled"
            case any = "any"
        }
    }
}
