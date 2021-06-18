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


/// Friends list from a social network
public struct SocialNetworkFriendsList
{
    /// List of data from social friends accounts.
    public let accountsData: [SocialAccountData]

    /// Maximum number of friends that are returned at a time.
    public let limit: Int

    /// Number of the elements from which the list is generated.
    public let offset: Int

    /// Name of a social provider.
    public let platform: String?

    /// Total number of friends that you can get.
    public let totalCount: Int

    /// Shows whether the social friends are from your game.
    public let withLoginId: Bool?
}

extension SocialNetworkFriendsList
{
    public struct SocialAccountData
    {
        /// Friend’s avatar from a social provider.
        public let avatar: String?

        /// Friend’s name from a social provider.
        public let name: String

        /// Name of a social provider.
        public let platform: String

        /// User tag without \"#\" at the beginning.
        /// Can have no unique value and can be used in the [Search users by nickname](https://developers.xsolla.com/login-api/user-account/managed-by-client/user-friends/search-users-by-nickname) call.
        public let tag: String?

        /// User ID from a social provider.
        public let userId: String

        /// The Xsolla Login user ID.
        /// You can find it in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **Users** > **Username/ID**.
        public let loginId: String?
    }
}

extension SocialNetworkFriendsList
{
    init(fromResponse response: GetSocialNetworkFriendsResponse)
    {
        accountsData = response.data.map
        {
            SocialAccountData(avatar: $0.avatar,
                              name: $0.name,
                              platform: $0.platform,
                              tag: $0.tag,
                              userId: $0.userId,
                              loginId: $0.loginId)
        }
        limit = response.limit
        offset = response.offset
        platform = response.platform
        totalCount = response.totalCount
        withLoginId = response.withLoginId
    }
}
