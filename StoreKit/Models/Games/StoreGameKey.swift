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

public struct StoreGameKey
{
    /// Unique game key ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Game key name.
    public let name: String

    /// Groups the game key belongs to.
    public let groups: [StoreItemGroupShort]

    /// Type of item: `game_key`.
    public let type: String

    /// Game key description.
    public let gameKeyDescription: String

    /// Image URL.
    public let imageURL: String

    /// List of attributes and their values corresponding to the game key. Can be used for catalog filtering.
    public let attributes: [StoreItemAttribute]

    /// Whether game key is free.
    public let isFree: Bool

    /// Game key prices.
    public let price: StoreItemPrice

    /// Game key prices in virtual currency.
    public let virtualPrices: [StoreItemVirtualPrice]

    /// Unique DRM ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let drmSku: String

    /// DRM name.
    public let drmName: String

    /// Whether game key is pre-order and the release date hasn't passed.
    public let isPreOrder: Bool

    /// Whether game key has keys for sale.
    public let hasKeys: Bool

    /// Game key release date in the ISO 8601 format.
    public let releaseDate: Date
}
