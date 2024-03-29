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

struct GetUserVirtualCurrencyBalanceResponse: Decodable
{
    let items: [Item]
}

extension GetUserVirtualCurrencyBalanceResponse
{
    struct Item: Decodable
    {
        let sku: String
        let type: String
        let name: String
        let amount: Int
        let description: String?
        let imageUrl: String?
        
        enum CodingKeys: String, CodingKey
        {
            case sku
            case type
            case name
            case amount
            case description
            case imageUrl = "image_url"
        }
    }
}
