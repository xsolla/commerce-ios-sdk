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

// swiftlint:disable line_length

protocol LoginAsyncUtilityProfileProtocol: AsyncUtilityProtocol
{
    func fetchUserProfileDetails() -> Promise<UserProfileDetails>
    func uploadMandatoryDetails(_ details: UserProfileMandatoryDetailsProtocol) -> Promise<UserProfileDetails>

    func uploadPhone(_ phone: String?) -> Promise<Void>
    func uploadUserPicture(url: URL) -> Promise<String>
    func removeUserPicture() -> Promise<Void>

    func upgradeAccount(withUsername username: String, password: String, email: String, promoEmailAgreement: Bool, redirectUri: String?) -> Promise<Bool>
}

extension LoginAsyncUtilityProfileProtocol
{
    func upgradeAccount(withUsername username: String, password: String, email: String, promoEmailAgreement: Bool, redirectUri: String? = nil) -> Promise<Bool>
    {
        upgradeAccount(withUsername: username, password: password, email: email, promoEmailAgreement: promoEmailAgreement, redirectUri: redirectUri)
    }
}
