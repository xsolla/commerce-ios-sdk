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
    let hasMore: Bool
    let items: [Item]
    
    enum CodingKeys: String, CodingKey
    {
        case hasMore = "has_more"
        case items = "items"
    }
}

extension GetVirtualCurrencyPackagesResponse
{
    struct Item: Decodable
    {
        let sku: String
        let name: String
        let groups: [GroupResponse]
        let attributes: [AttributeResponse]
        let type: String
        let bundleType: String
        let description: String?
        let imageUrl: String?
        let isFree: Bool
        let price: PriceResponse?
        let virtualPrices: [VirtualPriceResponse]
        let content: [ContentItem]
        let promotions : [StoreItemPromotionResponse]
        
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
            case promotions = "promotions"
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
        let inventoryOptions: InventoryOptionsResponse
        
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
    }
}
