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

struct StoreItemPromotionResponse: Decodable
{
    public let name: String
    public let dateStart: String?
    public let dateEnd: String?
    public let discount: DiscountResponse
    public let bonus: [BonusResponse]
    public let limits: LimitsResponse?

    enum CodingKeys: String, CodingKey
    {
        case name
        case dateStart = "date_start"
        case dateEnd = "date_end"
        case discount
        case bonus
        case limits
    }

    public struct DiscountResponse : Decodable
    {
        public let percent: String?
        public let value: String?
        
        enum CodingKeys: String, CodingKey
        {
            case percent
            case value
        }
    }

    public struct BonusResponse : Decodable
    {
        public let sku: String
        public let quantity: Int
        
        enum CodingKeys: String, CodingKey
        {
            case sku
            case quantity
        }
    }

    public struct LimitsResponse : Decodable
    {
        public let perUser: LimitsPerUserResponse
        
        enum CodingKeys: String, CodingKey
        {
            case perUser = "per_user"
        }
    }

    public struct LimitsPerUserResponse : Decodable
    {
        public let available: Int
        public let total: Int
        
        enum CodingKeys: String, CodingKey
        {
            case available
            case total
        }
    }
}
