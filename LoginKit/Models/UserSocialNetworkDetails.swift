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

/// Information about user's social network
public struct UserSocialNetworkInfo
{
    /// User's full name.
    public let userFullName: String?

    /// User's nickname.
    public let userNickname: String?

    /// User's picture URL.
    public let userPictureURL: URL?

    /// Social network name.
    public let socialNetworkName: String

    /// Social network ID.
    public let socialNetworkId: String
}

extension UserSocialNetworkInfo
{
    init(fromResponse response: SocialNetworkResponse)
    {
        userFullName = response.fullName
        userNickname = response.nickname
        socialNetworkName = response.provider
        socialNetworkId = response.socialId

        if let pictureURLString = response.picture
        {
            userPictureURL = URL(string: pictureURLString)
        }
        else
        {
            userPictureURL = nil
        }
    }
}
