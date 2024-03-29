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

/// Structure containing user public profile
public struct UserPublicProfile
{
    /// URL of the user avatar.
    public let avatar: String?

    /// Date of the last user login in the [RFC3339 format](https://www.ietf.org/rfc/rfc3339.txt).
    public let lastLogin: String

    /// User nickname.
    public let nickname: String?

    /// Date of user registration in the [RFC3339 format](https://www.ietf.org/rfc/rfc3339.txt).
    public let registered: String

    /// User tag without "#" at the beginning. Can have no unique value and can be used in the [Search users by nickname](https://developers.xsolla.com/login-api/user-account/managed-by-client/user-friends/search-users-by-nickname) call.
    public let tag: String?

    /// The Xsolla Login user ID. You can find it in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **Users** > **Username/ID**.
    public let userID: String
}

extension UserPublicProfile
{
    init(fromResponse response: GetUserPublicProfileResponse)
    {
        avatar = response.avatar
        lastLogin = response.lastLogin
        nickname = response.nickname
        registered = response.registered
        tag = response.tag
        userID = response.userID
    }
}
