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

struct FillCartWithItemsResponse: Decodable
{
    let cartId: String
    let price: PriceResponse?
    let isFree: Bool
    let items: [CartItemResponse]
    let warnings: [WarningResponse]

    enum CodingKeys: String, CodingKey
    {
        case cartId = "cart_id"
        case price
        case isFree = "is_free"
        case items
        case warnings
    }
}

extension FillCartWithItemsResponse
{
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        cartId = try container.decode(String.self, forKey: .cartId)
        price = try container.decode(PriceResponse?.self, forKey: .price)
        isFree = try container.decode(Bool.self, forKey: .isFree)
        items = try container.decode([CartItemResponse].self, forKey: .items)
        warnings = try container.decodeIfPresent([WarningResponse].self, forKey: .warnings) ?? []
    }
}
