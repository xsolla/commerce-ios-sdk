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

public struct StoreBundle
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Item name.
    public let name: String

    /// Groups the item belongs to.
    public let groups: [StoreItemGroupShort]

    /// List of attributes and their values corresponding to the item. Can be used for catalog filtering.
    public let attributes: [StoreItemAttribute]

    /// Type of the item.
    public let type: String

    /// Item description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String?

    /// Always false.
    public let isFree: Bool

    /// Item price.
    public let price: StoreItemPrice?

    /// Item price in virtual currency with a discount.
    public let virtualPrices: [StoreItemVirtualPrice]

    /// Type of the bundle. In this case it is always `standart`.
    public let bundleType: String

    /// Sum of the bundle content prices.
    public let totalContentPrice: StoreItemPrice?

    /// Bundle package content.
    public let content: [ContentItem]

    /// Bundle package content item.
    public struct ContentItem
    {
        /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, dashes, and underscores.
        public let sku: String

        /// Item name.
        public let name: String

        /// Groups the item belongs to.
        public let groups: [StoreItemGroupShort]

        /// List of attributes and their values corresponding to the item. Can be used for catalog filtering.
        public let attributes: [StoreItemAttribute]

        /// Type of item: `virtual_good`, `virtual_currency`, `bundle`.
        public let type: String

        /// Item description.
        public let description: String?

        /// Image URL.
        public let imageUrl: String?

        /// If `true`, the item is free.
        public let isFree: Bool

        /// Item prices.
        public let price: StoreItemPrice?

        /// Virtual item prices in virtual currency.
        public let virtualPrices: [StoreItemVirtualPrice]

        /// Defines the inventory item options.
        public let inventoryOptions: StoreItemInventoryOptions

        /// Type of the virtual item.
        public let virtualItemType: String

        /// Quantity of the same item in a package.
        public let quantity: Int
    }
}

extension StoreBundle
{
    init(fromGetBundleListResponse response: GetBundlesListResponse.Item)
    {
        self.sku = response.sku
        self.name = response.name
        self.groups = response.groups.map { StoreItemGroupShort(externalId: $0.externalId, name: $0.name) }
        self.description = response.description
        self.attributes = response.attributes.map { StoreItemAttribute(fromAPIResponse: $0) }
        self.type = response.type
        self.bundleType = response.bundleType
        self.imageUrl = response.imageUrl
        self.isFree = response.isFree
        self.price = StoreItemPrice(fromOptionalAPIResponse: response.price)
        self.totalContentPrice = StoreItemPrice(fromOptionalAPIResponse: response.totalContentPrice)
        self.virtualPrices = response.virtualPrices.map { StoreItemVirtualPrice(fromAPIResponse: $0) }

        self.content = response.content.map
        { item in

            let price = StoreItemPrice(fromOptionalAPIResponse: item.price)
            let virtualPrices = item.virtualPrices.map { StoreItemVirtualPrice(fromAPIResponse: $0) }
            let attributes = item.attributes.map { StoreItemAttribute(fromAPIResponse: $0) }
            let groups = item.groups.map { StoreItemGroupShort(externalId: $0.externalId, name: $0.name) }
            let inventoryOptions = StoreItemInventoryOptions(fromAPIResponse: item.inventoryOptions)

            return ContentItem(sku: item.sku,
                               name: item.name,
                               groups: groups,
                               attributes: attributes,
                               type: item.type,
                               description: item.description,
                               imageUrl: item.imageUrl,
                               isFree: item.isFree,
                               price: price,
                               virtualPrices: virtualPrices,
                               inventoryOptions: inventoryOptions,
                               virtualItemType: item.virtualItemType,
                               quantity: item.quantity)
        }
    }

    init(fromGetBundleResponse response: GetBundleResponse)
    {
        self.sku = response.sku
        self.name = response.name
        self.groups = response.groups.map { StoreItemGroupShort(externalId: $0.externalId, name: $0.name) }
        self.description = response.description
        self.attributes = response.attributes.map { StoreItemAttribute(fromAPIResponse: $0) }
        self.type = response.type
        self.bundleType = response.bundleType
        self.imageUrl = response.imageUrl
        self.isFree = response.isFree
        self.price = StoreItemPrice(fromOptionalAPIResponse: response.price)
        self.totalContentPrice = StoreItemPrice(fromOptionalAPIResponse: response.totalContentPrice)
        self.virtualPrices = response.virtualPrices.map { StoreItemVirtualPrice(fromAPIResponse: $0) }

        self.content = response.content.map
        { item in

            let price = StoreItemPrice(fromOptionalAPIResponse: item.price)
            let virtualPrices = item.virtualPrices.map { StoreItemVirtualPrice(fromAPIResponse: $0) }
            let attributes = item.attributes.map { StoreItemAttribute(fromAPIResponse: $0) }
            let groups = item.groups.map { StoreItemGroupShort(externalId: $0.externalId, name: $0.name) }
            let inventoryOptions = StoreItemInventoryOptions(fromAPIResponse: item.inventoryOptions)

            return ContentItem(sku: item.sku,
                               name: item.name,
                               groups: groups,
                               attributes: attributes,
                               type: item.type,
                               description: item.description,
                               imageUrl: item.imageUrl,
                               isFree: item.isFree,
                               price: price,
                               virtualPrices: virtualPrices,
                               inventoryOptions: inventoryOptions,
                               virtualItemType: item.virtualItemType,
                               quantity: item.quantity)
        }
    }
}
