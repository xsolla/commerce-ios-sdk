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

import Foundation

struct GetOrderResponse: Decodable
{
    let orderId: Int
    let status: String?
    let content: Content?
    
    enum CodingKeys: String, CodingKey
    {
        case orderId = "order_id"
        case status = "status"
        case content = "content"
    }
}

extension GetOrderResponse
{
    struct Content: Decodable
    {
        let price: PriceResponse?
        let virtualPrice: VirtualPriceResponse?
        let isFree: Bool
        let items: [Item]?
        
        enum CodingKeys: String, CodingKey
        {
            case price = "price"
            case virtualPrice = "virtual_price"
            case isFree = "is_free"
            case items = "items"
        }
    }
}

extension GetOrderResponse.Content
{
    struct Item: Decodable
    {
        let sku: String?
        let quantity: Int
        let isFree: Bool
        let price: PriceResponse?
        
        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case quantity = "quantity"
            case isFree = "is_free"
            case price = "price"
        }
    }
}
