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

struct GetCouponRewardsResponse: Decodable
{
    let bonus: [Bonus]
    let isSelectable: Bool
    
    enum CodingKeys: String, CodingKey
    {
        case bonus = "bonus"
        case isSelectable = "is_selectable"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bonus = try container.decode([Bonus].self, forKey: .bonus)
        isSelectable = try container.decode(Bool.self, forKey: .isSelectable)
    }
}

extension GetCouponRewardsResponse
{
    struct Bonus: Decodable
    {
        let item: Item
        let quantity: Int
        
        enum CodingKeys: String, CodingKey
        {
            case item = "item"
            case quantity = "quantity"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            item = try container.decode(Item.self, forKey: .item)
            quantity = try container.decode(Int.self, forKey: .quantity)
        }
    }
}

extension GetCouponRewardsResponse.Bonus
{
    struct Item: Decodable
    {
        let sku: String
        let name: String
        let type: String
        let description: String?
        let imageUrl: String?
        let unitItems: [UnitItem]?
        
        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case name = "name"
            case type = "type"
            case description = "description"
            case imageUrl = "image_url"
            case unitItems = "unit_items"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sku = try container.decode(String.self, forKey: .sku)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(String.self, forKey: .type)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            unitItems = try container.decodeIfPresent([UnitItem].self, forKey: .unitItems)
        }
    }
}

extension GetCouponRewardsResponse.Bonus.Item
{
    struct UnitItem: Decodable
    {
        let sku: String
        let type: String
        let name: String
        let drmName: String
        let drmSku: String
        
        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case type = "type"
            case name = "name"
            case drmName = "drm_name"
            case drmSku = "drm_sku"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sku = try container.decode(String.self, forKey: .sku)
            type = try container.decode(String.self, forKey: .type)
            name = try container.decode(String.self, forKey: .name)
            drmName = try container.decode(String.self, forKey: .drmName)
            drmSku = try container.decode(String.self, forKey: .drmSku)
        }
    }
}
