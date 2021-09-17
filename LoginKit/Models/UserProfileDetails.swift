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

/// User profile details.
public struct UserProfileDetails
{
    /// Details of the user's ban. The value is `nil` for the users not from the ban list.
    public var ban: BanDetails?

    /// User birth day.
    public var birthday: Date?

    /// User birth date confirmed by [okname](https://www.ok-name.co.kr/).
    /// For Korean users only.
    public var connectionInformation: String?

    /// User country.
    public var country: String?

    /// User email address.
    public var email: String?

    /// ID of the user in your game.
    /// To use the ID from your game, link the IDs by the [Link user IDs via external ID](https://developers.xsolla.com/login-api/methods/users/link-user-ids-via-external-id) method.
    public var externalId: String?

    /// User first name.
    public var firstName: String?

    /// User gender.
    public var gender: Gender?

    /// Details about the groups the user was added to.
    public var groups: [Group]

    /// User ID.
    public var id: String

    /// Date of the last user login.
    public var lastLogin: Date

    /// User last name.
    public var lastName: String?

    /// User name in a social network.
    public var name: String?

    /// User nickname.
    public var nickname: String?

    /// User phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers).
    public var phone: String?

    /// Link to the user profile picture.
    public var picture: String?

    /// Date of user registration.
    public var registered: Date

    /// User tag without \"#\" at the beginning.
    /// Can have no unique value and can be used in the [Search users by nickname](https://developers.xsolla.com/login-api/methods/users/search-users-by-nickname) method.
    public var tag: String?

    /// Username.
    public var username: String?

    /// Whether the user is anonymous.
    /// The anonymous user is a user created via device ID or custom ID and doesn’t have an alternative authentication method added (e.g., username/email and password).
    public var isAnonymous: Bool

    /// Whether the user email is verified.
    public var isLastEmailConfirmed: Bool?

    /// Whether the user is anonymous. The anonymous user is a user created via device ID or custom ID and doesn’t have an alternative authentication method added (e.g., username/email and password)
    public var isUserActive: Bool
}

public extension UserProfileDetails
{
    /// Details of the user's ban.
    struct BanDetails
    {
        /// Date when the user was banned.
        public var dateFrom: Date

        /// Date until the user remains banned.
        public var dateTo: Date?

        /// Reason the user ban.
        public var reason: String?
    }

    /// Details about the group.
    struct Group
    {
        /// Group ID.
        public var id: Int

        /// Whether the group is default.
        public var isDefault: Bool

        /// Whether the group can be deleted. Default groups can’t be deleted.
        public var isDeletable: Bool

        /// Group name.
        public var name: String
    }

    enum Gender: String
    {
        case female = "f"
        case male = "m"
        case other = "other"
        case unspecified = "prefer not to answer"
    }
}

extension UserProfileDetails
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
        self.isAnonymous = response.isAnonymous
        self.isLastEmailConfirmed = response.isLastEmailConfirmed
        self.isUserActive = response.isUserActive
    }

    init(fromGetCurrentUserDetailsResponse response: UpdateCurrentUserDetailsResponse)
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
        self.isAnonymous = response.isAnonymous
        self.isLastEmailConfirmed = response.isLastEmailConfirmed
        self.isUserActive = response.isUserActive
    }
}
