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

/// Virtual item.
public struct StoreVirtualItem
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Item name.
    public let name: String

    /// Groups the item belongs to.
    public let groups: [StoreItemGroupShort]

    /// List of attributes and their values corresponding to the item. Can be used for catalog filtering.
    public let attributes: [StoreItemAttribute]

    /// Type of item: `virtual_good`, `virtual_currency`, and `bundle`.
    public let type: String

    /// Item description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String?

    /// If `true`, the item is free.
    public let isFree: Bool

    /// Item prices.
    public let price: StoreItemPrice?

    /// Virtual prices.
    public let virtualPrices: [StoreItemVirtualPrice]

    /// Defines the inventory item options.
    public let inventoryOptions: StoreItemInventoryOptions

    /// Type of virtual item.
    public let virtualItemType: String

    /// Promotion settings in Store.
    public let promotions: [StoreItemPromotion]

    /// Limit to the number of times one user can buy an item.
    public let limits: StoreItemLimits?
}

/// Virtual items.
public struct StoreVirtualItems
{
    public let hasMore: Bool
    public let items: [StoreVirtualItem]
    
    public var languageCode: String?
    public var countryCode: String?
}
