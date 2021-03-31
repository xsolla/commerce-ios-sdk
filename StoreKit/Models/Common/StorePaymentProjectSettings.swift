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

// swiftlint:disable redundant_string_enum_value

import Foundation

/// Custom project settings.
public struct StorePaymentProjectSettings
{
    public let ui: UISettings

    public init(ui: UISettings)
    {
        self.ui = ui
    }
}

extension StorePaymentProjectSettings
{
    public struct UISettings: Encodable
    {
        /// Payment UI theme. Can be `default` or `defaultDark`.
        public let theme: Theme

        public init(theme: Theme)
        {
            self.theme = theme
        }
    }
}

extension StorePaymentProjectSettings.UISettings
{
    public enum Theme: String
    {
        case `default` = "default"
        case defaultDark = "default_dark"
    }
}

extension StorePaymentProjectSettings: Encodable
{

}

extension StorePaymentProjectSettings.UISettings.Theme: Encodable
{
    enum CodingKeys: String, CodingKey
    {
        case theme = "theme"
    }

    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .theme)
    }
}
