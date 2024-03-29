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

public struct StoreCartItem
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Groups the item belongs to.
    public let groups: [StoreItemGroupShort]

    /// Item name.
    public let name: String

    /// List of attributes and their values corresponding to the item. Can be used for catalog filtering.
    public let attributes: [StoreItemAttribute]

    /// Type of item. Can be `virtual_good`, `virtual_currency`, or `bundle`.
    public let type: String

    /// Item description.
    public let description: String

    /// Image URL.
    public let imageUrl: String

    /// Item quantity.
    public let quantity: Int

    /// Item price.
    public let price: StoreItemPrice?

    /// Whether item is free.
    public let isFree: Bool

    /// Whether item was added to the cart as a bonus according to the promotion campaign.
    public let isBonus: Bool
}
