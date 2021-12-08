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

// swiftlint:disable redundant_string_enum_value
// swiftlint:disable nesting

import Foundation

struct GetCurrentUserFriendsResponse: Decodable
{
    let nextAfter: String?
    let nextURL: String?
    let relationships: [Relationship]
    
    enum CodingKeys: String, CodingKey
    {
        case nextAfter = "next_after"
        case nextURL = "next_url"
        case relationships = "relationships"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nextAfter = try container.decodeIfPresent(String.self, forKey: .nextAfter)
        nextURL = try container.decodeIfPresent(String.self, forKey: .nextURL)
        relationships = try container.decode([Relationship].self, forKey: .relationships)
    }
}

extension GetCurrentUserFriendsResponse
{
    struct Relationship: Decodable
    {
        let statusIncoming: String
        let statusOutgoing: String
        let updated: Date
        let user: UserDetail
        
        enum CodingKeys: String, CodingKey
        {
            case statusIncoming = "status_incoming"
            case statusOutgoing = "status_outgoing"
            case updated = "updated"
            case user = "user"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            statusIncoming = try container.decode(String.self, forKey: .statusIncoming)
            statusOutgoing = try container.decode(String.self, forKey: .statusOutgoing)
            user = try container.decode(UserDetail.self, forKey: .user)
            
            let timeInterval = try container.decode(Double.self, forKey: .updated)
            let updatedDate = Date(timeIntervalSince1970: timeInterval)
            updated = updatedDate
        }
    }
}

extension GetCurrentUserFriendsResponse.Relationship
{
    struct UserDetail: Decodable
    {
        let id: String
        let name: String?
        let nickname: String?
        let picture: String?
        let presence: String
        let tag: String?
        
        enum CodingKeys: String, CodingKey
        {
            case id = "id"
            case name = "name"
            case nickname = "nickname"
            case picture = "picture"
            case presence = "presence"
            case tag = "tag"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
            picture = try container.decodeIfPresent(String.self, forKey: .picture)
            presence = try container.decode(String.self, forKey: .presence)
            tag = try container.decodeIfPresent(String.self, forKey: .tag)
        }
    }
}
