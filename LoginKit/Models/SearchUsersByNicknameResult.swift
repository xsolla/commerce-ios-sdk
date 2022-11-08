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

/// Structure contains the results of the search by nickname
public struct SearchUsersByNicknameResult
{
    /// Number of the elements from which the list is generated.
    public let offset: Int

    /// Total number of users that you can get.
    public let totalCount: Int

    /// List of users’ data.
    public let users: [User]

    public struct User
    {
        /// URL of the user avatar.
        public let avatar: String?

        /// Shows whether the user who initiated a search or not.
        public let isMe: Bool

        /// Date of the last user login in the [RFC3339 format](https://www.ietf.org/rfc/rfc3339.txt).
        public let lastLogin: String

        /// User nickname.
        public let nickname: String

        /// Date of user registration in the [RFC3339 format](https://www.ietf.org/rfc/rfc3339.txt).
        public let registered: String

        /// User tag without "#" at the beginning. Can have no unique value.
        public let tag: String?

        /// The Xsolla Login user ID. You can find it in [Publisher
        /// Account](https://publisher.xsolla.com/) > your Login project > **Users** >
        /// **Username/ID**.
        public let userID: String
    }
}

extension SearchUsersByNicknameResult
{
    init(fromResponse response: SearchUsersByNicknameResponse)
    {
        offset = response.offset
        totalCount = response.totalCount
        users = response.users.map { User(fromResponse: $0) }
    }
}

extension SearchUsersByNicknameResult.User
{
    init(fromResponse response: SearchUsersByNicknameResponse.User)
    {
        avatar = response.avatar
        isMe = response.isMe
        lastLogin = response.lastLogin
        nickname = response.nickname
        registered = response.registered
        tag = response.tag
        userID = response.userID
    }
}
