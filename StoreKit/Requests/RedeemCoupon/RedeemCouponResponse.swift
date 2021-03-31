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

struct RedeemCouponResponse: Decodable
{
    let items: [Item]
    
    enum CodingKeys: String, CodingKey
    {
        case items = "items"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([Item].self, forKey: .items)
    }
}

extension RedeemCouponResponse
{
    struct Item: Decodable
    {
        let sku: String
        let groups: [StoreResponseCommon.Group]?
        let name: String?
        let type: String
        let description: String?
        let imageUrl: String?
        let quantity: Int
        let isFree: Bool
        
        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case groups = "groups"
            case name = "name"
            case type = "type"
            case description = "description"
            case imageUrl = "image_url"
            case quantity = "quantity"
            case isFree = "is_free"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sku = try container.decode(String.self, forKey: .sku)
            groups = try container.decodeIfPresent([StoreResponseCommon.Group].self, forKey: .groups)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            type = try container.decode(String.self, forKey: .type)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            quantity = try container.decode(Int.self, forKey: .quantity)
            isFree = try container.decode(Bool.self, forKey: .isFree)
        }
    }
}
