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

public struct StoreRewardItem
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Item name.
    public let name: String

    /**
     Type of item.

     Can be:
     * `virtual_good`
     * `virtual_currency`
     * `bundle`
     * `physical_good`
     * `unit`
     */
    public let type: String

    /// Item description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String?

    /**
     If the item has the unit type, it includes all items in the unit.
     In most cases the user should choose one of them as a coupon bonus.
     */
    public let unitItems: [UnitItem]?
}

public extension StoreRewardItem
{
    struct UnitItem
    {
        /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
        public let sku: String

        /// Type of the item: `game_key`.
        public let type: String

        /// Item name.
        public let name: String

        /// DRM name.
        public let drmName: String

        /// Unique DRM ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
        public let drmSKU: String
    }
}
