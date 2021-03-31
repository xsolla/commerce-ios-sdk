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

/// Store order.
public struct StoreOrder
{
    /// Order ID.
    public let orderId: Int

    /// Order status. May be: `new`, `paid`, `done`, `canceled`.
    public let status: String?

    /// Order details.
    public let content: Content?
}

extension StoreOrder
{
    /// Order details.
    public struct Content
    {
        /// Order price.
        public let price: StoreItemPrice?

        /// Order price in virtual currency.
        public let virtualPrice: StoreItemVirtualPrice?

        /// If `true`, the order is free.
        public let isFree: Bool

        /// Items list.
        public let items: [Item]?
    }
}

extension StoreOrder.Content
{
    /// Order's content item.
    public struct Item
    {
        /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
        public let sku: String?

        /// Item quantity.
        public let quantity: Int

        /// If `true`, the order is free.
        public let isFree: Bool

        /// Item price.
        public let price: StoreItemPrice?
    }
}

extension StoreOrder
{
    init(fromGetOrderResponse response: GetOrderResponse)
    {
        self.orderId = response.orderId
        self.status = response.status

        if let content = response.content
        {
            let items = content.items?.map
            {
                Content.Item(sku: $0.sku,
                             quantity: $0.quantity,
                             isFree: $0.isFree,
                             price: StoreItemPrice(fromOptionalAPIResponse: $0.price))
            }
            self.content = Content(price: StoreItemPrice(fromOptionalAPIResponse: content.price),
                                   virtualPrice: StoreItemVirtualPrice(fromOptionalAPIResponse: content.virtualPrice),
                                   isFree: content.isFree,
                                   items: items)
        }
        else
        {
            self.content = nil
        }
    }
}
