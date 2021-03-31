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

/// Common response container for Store API.
struct StoreResponseCommon
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

    struct Price: Decodable
    {
        let amount: Double?
        let amountWithoutDiscount: Double?
        let currency: String?

        enum CodingKeys: String, CodingKey
        {
            case amount = "amount"
            case amountWithoutDiscount = "amount_without_discount"
            case currency = "currency"
        }

        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            amount = (try? container.decodeIfPresent(Double.self, forKey: .amount))
                ?? Double((try? container.decodeIfPresent(String.self, forKey: .amount)) ?? "")

            amountWithoutDiscount = (try? container.decodeIfPresent(Double.self, forKey: .amountWithoutDiscount))
                ?? Double((try? container.decodeIfPresent(String.self, forKey: .amountWithoutDiscount)) ?? "")

            currency = try container.decodeIfPresent(String.self, forKey: .currency)
        }
    }

    struct VirtualPrice: Decodable
    {
        let amount: Int?
        let amountWithoutDiscount: Int?
        let sku: String
        let isDefault: Bool
        let imageUrl: String?
        let name: String
        let type: String
        let description: String?

        enum CodingKeys: String, CodingKey
        {
            case amount = "amount"
            case amountWithoutDiscount = "amount_without_discount"
            case sku = "sku"
            case isDefault = "is_default"
            case imageUrl = "image_url"
            case name = "name"
            case type = "type"
            case description = "description"
        }

        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            amount = try container.decode(Int.self, forKey: .amount)
            amountWithoutDiscount = try container.decode(Int.self, forKey: .amountWithoutDiscount)
            sku = try container.decode(String.self, forKey: .sku)
            isDefault = try container.decode(Bool.self, forKey: .isDefault)
            imageUrl = try container.decode(String?.self, forKey: .imageUrl)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(String.self, forKey: .type)
            description = try container.decode(String?.self, forKey: .description)
        }
    }

    struct InventoryOptions: Decodable
    {
        let consumable: Consumable?
        let expirationPeriod: ExpirationPeriod?

        enum CodingKeys: String, CodingKey
        {
            case consumable = "consumable"
            case expirationPeriod = "expiration_period"
        }

        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            consumable = try container.decode(Consumable?.self, forKey: .consumable)
            expirationPeriod = try container.decode(ExpirationPeriod?.self, forKey: .expirationPeriod)
        }
    }

    struct Consumable: Decodable
    {
        let usagesCount: Int?

        enum CodingKeys: String, CodingKey
        {
            case usagesCount = "usages_count"
        }

        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            usagesCount = try container.decode(Int?.self, forKey: .usagesCount)
        }
    }

    struct ExpirationPeriod: Decodable
    {
        let type: String
        let value: Int

        enum CodingKeys: String, CodingKey
        {
            case type = "type"
            case value = "value"
        }

        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            value = try container.decode(Int.self, forKey: .value)
        }
    }

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
