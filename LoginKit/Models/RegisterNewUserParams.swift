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

/// Set of parameters used to register a new user.
public struct RegisterNewUserParams
{
    /// Username.
    public let username: String

    /// Password.
    public let password: String

    /// Email.
    public let email: String

    /// Whether the user gave consent to processing of their personal data.
    public let acceptConsent: Bool?

    /// Parameters for advanced user registration. To use this feature, contact your Account Manager.
    public let fields: [String: String]?

    /// User's consent to receive the newsletter.
    public let promoEmailAgreement: Int?

    public init(username: String,
                password: String,
                email: String,
                acceptConsent: Bool?,
                fields: [String: String]?,
                promoEmailAgreement: Int?)
    {
        self.username = username
        self.password = password
        self.email = email
        self.acceptConsent = acceptConsent
        self.fields = fields
        self.promoEmailAgreement = promoEmailAgreement
    }
}
