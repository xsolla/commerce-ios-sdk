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

/// User details.
public struct LoginUserDetails
{
    /// Details of the user's ban. The value is `nil` for the users not from the ban list.
    public let ban: BanDetails?

    /// User birth day.
    public let birthday: Date?

    /// User birth date confirmed by [okname](https://www.ok-name.co.kr/).
    /// For Korean users only.
    public let connectionInformation: String?

    /// User country.
    public let country: String?

    /// User email address.
    public let email: String?

    /// ID of the user in your game.
    /// To use the ID from your game, link the IDs by the [Link user IDs via external ID](https://developers.xsolla.com/login-api/methods/users/link-user-ids-via-external-id) method.
    public let externalId: String?

    /// User first name.
    public let firstName: String?

    /// User gender.
    public let gender: Gender?

    /// Details about the groups the user was added to.
    public let groups: [Group]

    /// User ID.
    public let id: String

    /// Date of the last user login.
    public let lastLogin: Date

    /// User last name.
    public let lastName: String?

    /// User name in a social network.
    public let name: String?

    /// User nickname.
    public let nickname: String?

    /// User phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers).
    public let phone: String?

    /// Link to the user profile picture.
    public let picture: String?

    /// Date of user registration.
    public let registered: Date

    /// User tag without \"#\" at the beginning.
    /// Can have no unique value and can be used in the [Search users by nickname](https://developers.xsolla.com/login-api/methods/users/search-users-by-nickname) method.
    public let tag: String?

    /// Username.
    public let username: String?
}

public extension LoginUserDetails
{
    /// Details of the user's ban.
    struct BanDetails
    {
        /// Date when the user was banned.
        public let dateFrom: Date

        /// Date until the user remains banned.
        public let dateTo: Date?

        /// Reason the user ban.
        public let reason: String?
    }

    /// Details about the group.
    struct Group
    {
        /// Group ID.
        public let id: Int

        /// Shows whether the group is default or not.
        public let isDefault: Bool

        /// Shows whether the group can be deleted or not. Default groups can’t be deleted.
        public let isDeletable: Bool

        /// Group name.
        public let name: String
    }

    enum Gender: String
    {
        case female = "female"
        case male = "male"
        case other = "other"
        case preferNotToAnswer = "prefer not to answer"
    }
}

extension LoginUserDetails
{
    init(fromGetCurrentUserDetailsResponse response: GetCurrentUserDetailsResponse)
    {
        var banDetails: BanDetails?
        if let banResponse = response.ban
        {
            banDetails = BanDetails(dateFrom: banResponse.dateFrom,
                                    dateTo: banResponse.dateTo,
                                    reason: banResponse.reason)

        }
        self.ban = banDetails
        self.birthday = response.birthday
        self.connectionInformation = response.connectionInformation
        self.country = response.country
        self.email = response.email
        self.externalId = response.externalId
        self.firstName = response.firstName
        self.gender = Gender(rawValue: response.gender ?? "")
        self.groups = response.groups.map
        {
            Group(id: $0.id, isDefault: $0.isDefault, isDeletable: $0.isDeletable, name: $0.name)
        }
        self.id = response.id
        self.lastLogin = response.lastLogin
        self.lastName = response.lastName
        self.name = response.name
        self.nickname = response.nickname
        self.phone = response.phone
        self.picture = response.picture
        self.registered = response.registered
        self.tag = response.tag
        self.username = response.username
    }
}
