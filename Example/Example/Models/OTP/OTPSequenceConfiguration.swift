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

import UIKit

struct OTPSequenceConfiguration
{
    let l10n: Localization

    struct Localization
    {
        let startTitle: String
        let startPlaceholder: String
        let startActionButton: String
        let codeTitle: String
        let codePlaceholder: String
        let codeActionButton: String
        let codeCodeExpireIn: String
        let codeCodeExpired: String
        let codeResendCode: String
        let invalidPayloadError: String
    }

    var configurePayloadTextField: ((UITextField) -> Void)?
    var configureCodeTextField: ((UITextField) -> Void)?
}

extension OTPSequenceConfiguration
{
    static let email: OTPSequenceConfiguration =
    {
        let l10n = Localization.init(startTitle: L10n.Auth.Otp.Email.Start.title,
                                     startPlaceholder: L10n.Auth.Otp.Email.Start.payloadPlaceholder,
                                     startActionButton: L10n.Auth.Otp.Email.Start.actionButton,
                                     codeTitle: L10n.Auth.Otp.Email.Code.title,
                                     codePlaceholder: L10n.Auth.Otp.Email.Code.codePlaceholder,
                                     codeActionButton: L10n.Auth.Otp.Email.Code.actionButton,
                                     codeCodeExpireIn: L10n.Auth.Otp.Email.Code.codeExpireIn,
                                     codeCodeExpired: L10n.Auth.Otp.Email.Code.codeExpired,
                                     codeResendCode: L10n.Auth.Otp.Email.Code.resendCode,
                                     invalidPayloadError: L10n.Auth.Otp.Email.Start.invalidPayload)

        let configuration = Self(l10n: l10n)

        return configuration
    }()

    static let phone: OTPSequenceConfiguration =
    {
        let l10n = Localization.init(startTitle: L10n.Auth.Otp.Phone.Start.title,
                                     startPlaceholder: L10n.Auth.Otp.Phone.Start.payloadPlaceholder,
                                     startActionButton: L10n.Auth.Otp.Phone.Start.actionButton,
                                     codeTitle: L10n.Auth.Otp.Phone.Code.title,
                                     codePlaceholder: L10n.Auth.Otp.Phone.Code.codePlaceholder,
                                     codeActionButton: L10n.Auth.Otp.Phone.Code.actionButton,
                                     codeCodeExpireIn: L10n.Auth.Otp.Phone.Code.codeExpireIn,
                                     codeCodeExpired: L10n.Auth.Otp.Phone.Code.codeExpired,
                                     codeResendCode: L10n.Auth.Otp.Phone.Code.resendCode,
                                     invalidPayloadError: L10n.Auth.Otp.Phone.Start.invalidPayload)

        let configuration = Self(l10n: l10n)

        return configuration
    }()
}
