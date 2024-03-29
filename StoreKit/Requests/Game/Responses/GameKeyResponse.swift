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

struct GameKeyResponse: Decodable
{
    let sku: String
    let name: String
    let groups: [GroupResponse]
    let type: String
    let gameKeyDescription: String
    let imageURL: String
    let attributes: [AttributeResponse]
    let isFree: Bool
    let price: PriceResponse
    let virtualPrices: [VirtualPriceResponse]
    let drmSku: String
    let drmName: String
    let isPreOrder: Bool
    let hasKeys: Bool
    let releaseDate: Date

    enum CodingKeys: String, CodingKey
    {
        case sku
        case name
        case groups
        case type 
        case gameKeyDescription = "description"
        case imageURL = "image_url"
        case attributes
        case isFree = "is_free"
        case price
        case virtualPrices = "virtual_prices"
        case drmName = "drm_name"
        case drmSku = "drm_sku"
        case hasKeys = "has_keys"
        case isPreOrder = "is_pre_order"
        case releaseDate = "release_date"
    }
}
