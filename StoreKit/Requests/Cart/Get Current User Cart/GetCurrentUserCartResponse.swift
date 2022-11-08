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

struct GetCurrentUserCartResponse: Decodable
{
    let cartId: String
    let price: PriceResponse?
    let isFree: Bool
    let items: [CartItemResponse]

    enum CodingKeys: String, CodingKey
    {
        case cartId = "cart_id"
        case price
        case isFree = "is_free"
        case items
    }
}
