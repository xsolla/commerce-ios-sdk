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

struct GetItemsOfGroupResponse: Decodable
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

extension GetItemsOfGroupResponse
{
    struct Item: Decodable
    {
        let sku: String
        let name: String
        let groups: [StoreResponseCommon.Group]
        let attributes: [StoreResponseCommon.Attribute]
        let type: String
        let description: String?
        let imageUrl: String?
        let isFree: Bool
        let price: StoreResponseCommon.Price?
        let virtualPrices: [StoreResponseCommon.VirtualPrice]
        let inventoryOptions: StoreResponseCommon.InventoryOptions
        let virtualItemType: String
        
        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case name = "name"
            case groups = "groups"
            case attributes = "attributes"
            case type = "type"
            case description = "description"
            case imageUrl = "image_url"
            case isFree = "is_free"
            case price = "price"
            case virtualPrices = "virtual_prices"
            case inventoryOptions = "inventory_options"
            case virtualItemType = "virtual_item_type"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sku = try container.decode(String.self, forKey: .sku)
            name = try container.decode(String.self, forKey: .name)
            groups = try container.decode([StoreResponseCommon.Group].self, forKey: .groups)
            attributes = try container.decode([StoreResponseCommon.Attribute].self, forKey: .attributes)
            type = try container.decode(String.self, forKey: .type)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            isFree = try container.decode(Bool.self, forKey: .isFree)
            price = try container.decodeIfPresent(StoreResponseCommon.Price.self, forKey: .price)
            virtualPrices = try container.decode([StoreResponseCommon.VirtualPrice].self, forKey: .virtualPrices)
            inventoryOptions = try container.decode(StoreResponseCommon.InventoryOptions.self,
                                                    forKey: .inventoryOptions)
            virtualItemType = try container.decode(String.self, forKey: .virtualItemType)
        }
    }
}
