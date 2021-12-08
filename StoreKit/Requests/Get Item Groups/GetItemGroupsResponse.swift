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
// swiftlint:disable redundant_string_enum_value

import Foundation

struct GetItemGroupsResponse: Decodable
{
    let groups: [Group]
    
    enum CodingKeys: String, CodingKey
    {
        case groups = "groups"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groups = try container.decode([Group].self, forKey: .groups)
    }
}

extension GetItemGroupsResponse
{
    struct Group: Decodable
    {
        let externalId: String
        let name: String
        let description: String?
        let imageUrl: String?
        let order: Int
        let level: Int
        let children: [Group]?
        let parentExternalId: String?
        
        enum CodingKeys: String, CodingKey
        {
            case externalId = "external_id"
            case name = "name"
            case description = "description"
            case imageUrl = "image_url"
            case order = "order"
            case level = "level"
            case children = "children"
            case parentExternalId = "parent_external_id"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            externalId = try container.decode(String.self, forKey: .externalId)
            name = try container.decode(String.self, forKey: .name)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            order = try container.decode(Int.self, forKey: .order)
            level = try container.decode(Int.self, forKey: .level)
            children = try container.decodeIfPresent([Group].self, forKey: .children)
            parentExternalId = try container.decodeIfPresent(String.self, forKey: .parentExternalId)
        }
    }
}
