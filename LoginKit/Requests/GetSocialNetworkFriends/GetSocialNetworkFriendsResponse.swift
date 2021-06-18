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

// swiftlint:disable nesting

import Foundation

struct GetSocialNetworkFriendsResponse: Decodable
{
    let data: [SocialAccountData]
    let limit: Int
    let offset: Int
    let platform: String?
    let totalCount: Int
    let withLoginId: Bool?
    
    enum CodingKeys: String, CodingKey
    {
        case data = "data"
        case limit = "limit"
        case offset = "offset"
        case platform = "platform"
        case totalCount = "total_count"
        case withLoginId = "with_xl_uid"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([SocialAccountData].self, forKey: .data)
        limit = try container.decode(Int.self, forKey: .limit)
        offset = try container.decode(Int.self, forKey: .offset)
        platform = try container.decodeIfPresent(String.self, forKey: .platform)
        totalCount = try container.decode(Int.self, forKey: .totalCount)
        withLoginId = try container.decodeIfPresent(Bool.self, forKey: .withLoginId)
    }
}

extension GetSocialNetworkFriendsResponse
{
    struct SocialAccountData: Decodable
    {
        let avatar: String?
        let name: String
        let platform: String
        let tag: String?
        let userId: String
        let loginId: String?
        
        enum CodingKeys: String, CodingKey
        {
            case avatar = "avatar"
            case name = "name"
            case platform = "platform"
            case tag = "tag"
            case userId = "user_id"
            case loginId = "xl_uid"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
            name = try container.decode(String.self, forKey: .name)
            platform = try container.decode(String.self, forKey: .platform)
            tag = try container.decodeIfPresent(String.self, forKey: .tag)
            userId = try container.decode(String.self, forKey: .userId)
            loginId = try container.decodeIfPresent(String.self, forKey: .loginId)
        }
    }
}
