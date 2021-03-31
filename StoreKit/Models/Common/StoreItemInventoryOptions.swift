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

/// Defines the inventory item options.
public struct StoreItemInventoryOptions
{
    /// Defines the consumable properties if this is a consumable item, or null if this is a nonconsumable item.
    public let consumable: Consumable?

    /// Defines the expiration properties if this is an expiring item, or null if this is a nonexpiring item.
    public let expirationPeriod: ExpirationPeriod?

    public struct Consumable
    {
        /// Total number of remaining uses if this is a consumable item, or null if this is a nonconsumable item.
        public let usagesCount: Int?
    }

    /// Defines the expiration properties if this is an expiring item, or null if this is a nonexpiring item.
    public struct ExpirationPeriod
    {
        /// Defines type of expiration of a item.
        public let type: String

        /// Defines value for expiration period.
        public let value: Int
    }
}

extension StoreItemInventoryOptions
{
    init(fromAPIResponse response: StoreResponseCommon.InventoryOptions)
    {
        if let consumable = response.consumable
        {
            self.consumable = Consumable(usagesCount: consumable.usagesCount)
        }
        else
        {
            self.consumable = nil
        }

        if let expirationPeriod = response.expirationPeriod
        {
            self.expirationPeriod = ExpirationPeriod(type: expirationPeriod.type, value: expirationPeriod.value)
        }
        else
        {
            self.expirationPeriod = nil
        }
    }
}
