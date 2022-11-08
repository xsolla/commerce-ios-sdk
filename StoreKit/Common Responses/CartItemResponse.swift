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

import Foundation

struct CartItemResponse: Decodable
{
    let sku: String
    let groups: [GroupResponse]
    let name: String
    let attributes: [AttributeResponse]
    let type: String
    let description: String
    let imageUrl: String
    let quantity: Int
    let price: PriceResponse
    let isFree: Bool
    let isBonus: Bool

    enum CodingKeys: String, CodingKey
    {
        case sku
        case groups
        case name
        case attributes = "attributes"
        case type = "type"
        case description
        case imageUrl = "image_url"
        case quantity
        case price
        case isFree = "is_free"
        case isBonus = "is_bonus"
    }
}
