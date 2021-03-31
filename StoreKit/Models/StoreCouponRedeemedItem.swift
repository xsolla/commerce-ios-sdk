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

/// Item after a coupon is redeemed.
public struct StoreCouponRedeemedItem
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Groups the item belongs to.
    public let groups: [StoreItemGroupShort]?

    /// Item name.
    public let name: String?

    /// Type of the item: `virtual_good`, `virtual_currency`, `bundle`.
    public let type: String

    /// Item description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String?

    /// Quantity of the item.
    public let quantity: Int

    /// If `true`, the item is free.
    public let isFree: Bool
}

extension StoreCouponRedeemedItem
{
    init(fromRedeemCouponResponse response: RedeemCouponResponse.Item)
    {
        self.sku = response.sku
        self.groups = response.groups?.map { StoreItemGroupShort(externalId: $0.externalId, name: $0.name) }
        self.name = response.name
        self.type = response.type
        self.description = response.description
        self.imageUrl = response.imageUrl
        self.quantity = response.quantity
        self.isFree = response.isFree
    }
}
