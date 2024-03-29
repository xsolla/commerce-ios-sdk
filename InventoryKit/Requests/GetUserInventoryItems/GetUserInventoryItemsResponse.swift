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
            case sku
            case type
            case name
            case quantity
            case description
            case imageUrl = "image_url"
            case groups
            case attributes
            case remainingUses = "remaining_uses"
            case virtualItemType = "virtual_item_type"
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
            case name
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
            case name
            case values
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
            case value
        }
    }
}
