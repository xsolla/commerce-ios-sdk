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

struct GetVirtualItemsResponse: Decodable
{
    let items: [Item]
}

extension GetVirtualItemsResponse
{
    struct Item: Decodable
    {
        let sku: String
        let name: String
        let groups: [GroupResponse]
        let attributes: [AttributeResponse]
        let type: String
        let description: String?
        let imageUrl: String
        let isFree: Bool
        let price: PriceResponse?
        let virtualPrices: [VirtualPriceResponse]
        let inventoryOptions: InventoryOptionsResponse
        let virtualItemType: String
        let promotions: [StoreItemPromotionResponse]
        let limits: StoreItemLimitsResponse?

        enum CodingKeys: String, CodingKey
        {
            case sku
            case name
            case groups
            case attributes
            case type
            case description
            case imageUrl = "image_url"
            case isFree = "is_free"
            case priсe
            case virtualPrices = "virtual_prices"
            case inventoryOptions = "inventory_options"
            case virtualItemType = "virtual_item_type"
            case promotions = "promotions"
            case limits = "limits"
        }

        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sku = try container.decode(String.self, forKey: .sku)
            name = try container.decode(String.self, forKey: .name)
            groups = try container.decode([GroupResponse].self, forKey: .groups)
            attributes = try container.decode([AttributeResponse].self, forKey: .attributes)
            type = try container.decode(String.self, forKey: .type)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            imageUrl = try container.decode(String.self, forKey: .imageUrl)
            isFree = try container.decode(Bool.self, forKey: .isFree)
            price = try container.decodeIfPresent(PriceResponse.self, forKey: .priсe)
            virtualPrices = try container.decode([VirtualPriceResponse].self, forKey: .virtualPrices)
            inventoryOptions = try container.decode(InventoryOptionsResponse.self, forKey: .inventoryOptions)
            virtualItemType = try container.decode(String.self, forKey: .virtualItemType)
            promotions = try container.decode([StoreItemPromotionResponse].self, forKey: .promotions)
            limits = try container.decodeIfPresent(StoreItemLimitsResponse.self, forKey: .limits)
        }
    }
}
