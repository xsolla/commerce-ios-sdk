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

public struct StorePromocodeRewards
{
    /// List of rewards that user can get when redeeming promo code.
    public let rewards: [StoreReward]

    /// Percent discount. The price of cart will be decreased using a value calculated by using this percent and then rounded to 2 decimal places.
    public let discount: Discount?

    /// Whether user should choose the bonus before redeeming a promo code.
    public let isSelectable: Bool

    /// List of items that are discounted by a promo code.
    public let discountedItems: [DiscountedItem]
}

public extension StorePromocodeRewards
{
    struct DiscountedItem
    {
        /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
        public let sku: String

        /// Percent discount for item. The price of cart item will be decreased using a value calculated by using this percent and then rounded to 2 decimal places.
        public let discount: Discount
    }

    struct Discount
    {
        /// Percent discount for item. The price of cart item will be decreased using a value calculated by using this percent and then rounded to 2 decimal places.
        public let percent: String
    }
}
