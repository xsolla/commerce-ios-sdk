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

struct GetUserInventoryItemsResponse: Decodable
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

extension GetUserInventoryItemsResponse
{
    struct Item: Decodable
    {
        let instanceId: String?
        let sku: String
        let type: String
        let name: String
        let quantity: Int?
        let description: String?
        let imageUrl: String
        let groups: [Group]
        let attributes: [Attribute]
        let remainingUses: Int?
        let virtualItemType: String?
        
        enum CodingKeys: String, CodingKey
        {
            case instanceId = "instance_id"
            case sku = "sku"
            case type = "type"
            case name = "name"
            case quantity = "quantity"
            case description = "description"
            case imageUrl = "image_url"
            case groups = "groups"
            case attributes = "attributes"
            case remainingUses = "remaining_uses"
            case virtualItemType = "virtual_item_type"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            instanceId = try container.decodeIfPresent(String.self, forKey: .instanceId)
            sku = try container.decode(String.self, forKey: .sku)
            type = try container.decode(String.self, forKey: .type)
            name = try container.decode(String.self, forKey: .name)
            quantity = try container.decodeIfPresent(Int.self, forKey: .quantity)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decode(String.self, forKey: .imageUrl)
            groups = try container.decode([Group].self, forKey: .groups)
            attributes = try container.decode([Attribute].self, forKey: .attributes)
            remainingUses = try container.decodeIfPresent(Int.self, forKey: .remainingUses)
            virtualItemType = try container.decodeIfPresent(String.self, forKey: .virtualItemType)
        }
    }
}

extension GetUserInventoryItemsResponse.Item
{
    struct Group: Decodable
    {
        let externalId: String
        let name: String
        
        enum CodingKeys: String, CodingKey
        {
            case externalId = "external_id"
            case name = "name"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            externalId = try container.decode(String.self, forKey: .externalId)
            name = try container.decode(String.self, forKey: .name)
        }
    }
    
    struct Attribute: Decodable
    {
        let externalId: String
        let name: String
        let values: [Value]
        
        enum CodingKeys: String, CodingKey
        {
            case externalId = "external_id"
            case name = "name"
            case values = "values"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            externalId = try container.decode(String.self, forKey: .externalId)
            name = try container.decode(String.self, forKey: .name)
            values = try container.decode([Value].self, forKey: .values)
        }
    }
}

extension GetUserInventoryItemsResponse.Item.Attribute
{
    struct Value: Decodable
    {
        let externalId: String
        let value: String
        
        enum CodingKeys: String, CodingKey
        {
            case externalId = "external_id"
            case value = "value"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            externalId = try container.decode(String.self, forKey: .externalId)
            value = try container.decode(String.self, forKey: .value)
        }
    }
}
