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

/**
 Information about consuming item
 - `sku`: unique item ID.
 - `quantity`: if item is uncountable, should be 'null'.
 -  `instanceId`: if item is countable, should be 'null'.
 */
public struct InventoryConsumingItem
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Item quantity. If the item is uncountable, should be 'null'.
    public let quantity: Int?

    /// Instance item ID. If the item is countable, should be 'null'.
    public let instanceId: String?

    public init(sku: String, quantity: Int?, instanceId: String?)
    {
        self.sku = sku
        self.quantity = quantity
        self.instanceId = instanceId
    }
}
