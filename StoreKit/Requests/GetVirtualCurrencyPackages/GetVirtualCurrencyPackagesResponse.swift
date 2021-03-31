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

struct GetVirtualCurrencyPackagesResponse: Decodable
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

extension GetVirtualCurrencyPackagesResponse
{
    struct Item: Decodable
    {
        let sku: String
        let name: String
        let groups: [StoreResponseCommon.Group]
        let attributes: [StoreResponseCommon.Attribute]
        let type: String
        let bundleType: String
        let description: String?
        let imageUrl: String?
        let isFree: Bool
        let price: StoreResponseCommon.Price?
        let virtualPrices: [StoreResponseCommon.VirtualPrice]
        let content: [ContentItem]
        
        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case name = "name"
            case groups = "groups"
            case attributes = "attributes"
            case type = "type"
            case bundleType = "bundle_type"
            case description = "description"
            case imageUrl = "image_url"
            case isFree = "is_free"
            case price = "price"
            case virtualPrices = "virtual_prices"
            case content = "content"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sku = try container.decode(String.self, forKey: .sku)
            name = try container.decode(String.self, forKey: .name)
            groups = try container.decode([StoreResponseCommon.Group].self, forKey: .groups)
            attributes = try container.decode([StoreResponseCommon.Attribute].self, forKey: .attributes)
            type = try container.decode(String.self, forKey: .type)
            bundleType = try container.decode(String.self, forKey: .bundleType)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            isFree = try container.decode(Bool.self, forKey: .isFree)
            price = try container.decodeIfPresent(StoreResponseCommon.Price.self, forKey: .price)
            virtualPrices = try container.decode([StoreResponseCommon.VirtualPrice].self, forKey: .virtualPrices)
            content = try container.decode([ContentItem].self, forKey: .content)
        }
    }
}

extension GetVirtualCurrencyPackagesResponse.Item
{
    struct ContentItem: Decodable
    {
        let sku: String
        let name: String
        let type: String
        let description: String?
        let imageUrl: String?
        let quantity: Int
        let inventoryOptions: StoreResponseCommon.InventoryOptions
        
        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case name = "name"
            case type = "type"
            case description = "description"
            case imageUrl = "image_url"
            case quantity = "quantity"
            case inventoryOptions = "inventory_options"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sku = try container.decode(String.self, forKey: .sku)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(String.self, forKey: .type)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            quantity = try container.decode(Int.self, forKey: .quantity)
            inventoryOptions = try container.decode(StoreResponseCommon.InventoryOptions.self,
                                                    forKey: .inventoryOptions)
        }
    }
}
