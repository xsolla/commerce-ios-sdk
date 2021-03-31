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

/// Single item of user's inventory.
public struct InventoryItem
{
    /// Instance of the item ID.
    public let instanceId: String?

    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Type of the item.
    public let type: ItemType

    /// Item name.
    public let name: String

    /// Item quantity.
    public let quantity: Int?

    /// Item description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String

    /// Groups the item belongs to.
    public let groups: [InventoryItemGroup]

    /// List of attributes and their values corresponding to the item. Can be used for catalog filtering.
    public let attributes: [InventoryItemAttribute]

    /// Defines the consumable properties: number of remaining uses if this is a consumable item, or null if this is a non-consumable item.
    public let remainingUses: Int?

    /// Type of a virtual item.
    public let virtualItemType: VirtualItemType?

    /// Detailed subscription info. `Nil if item is not a subscription or info isn't loaded.
    public let detailedSubscriptionInfo: InventoryUserSubscription?
}

extension InventoryItem
{
    /// Type of the virtual item.
    public enum VirtualItemType: String
    {
        case consumable = "consumable"
        case nonConsumable = "non_consumable"
        case nonRenewingSubscription = "non_renewing_subscription"
    }

    /// Type of the item.
    public enum ItemType: String
    {
        case virtualCurrency = "virtual_currency"
        case virtualGood = "virtual_good"
    }
}

extension InventoryItem
{
    init(fromAPIResponse apiResponseModel: GetUserInventoryItemsResponse.Item)
    {
        guard let itemType = ItemType(rawValue: apiResponseModel.type) else
        {
            fatalError("Unsupported item type")
        }

        self.instanceId = apiResponseModel.instanceId
        self.sku = apiResponseModel.sku
        self.type = itemType
        self.name = apiResponseModel.name
        self.quantity = apiResponseModel.quantity
        self.description = apiResponseModel.description
        self.imageUrl = apiResponseModel.imageUrl
        self.remainingUses = apiResponseModel.remainingUses
        self.virtualItemType = VirtualItemType(rawValue: apiResponseModel.virtualItemType ?? "")

        self.groups = apiResponseModel.groups.map { InventoryItemGroup(externalId: $0.externalId, name: $0.name) }

        self.attributes = apiResponseModel.attributes.map
        { attribute in

            let values = attribute.values.map
            {
                InventoryItemAttribute.Value(externalId: $0.externalId, value: $0.value)
            }

            return InventoryItemAttribute(externalId: attribute.externalId, name: attribute.name, values: values)
        }

        self.detailedSubscriptionInfo = nil
    }

    func withSubscriptionInfo(_ subscriptionInfo: InventoryUserSubscription?) -> InventoryItem
    {
        let inventoryItem = InventoryItem(instanceId: self.instanceId,
                                          sku: self.sku,
                                          type: self.type,
                                          name: self.name,
                                          quantity: self.quantity,
                                          description: self.description,
                                          imageUrl: self.imageUrl,
                                          groups: self.groups,
                                          attributes: self.attributes,
                                          remainingUses: self.remainingUses,
                                          virtualItemType: self.virtualItemType,
                                          detailedSubscriptionInfo: subscriptionInfo)
        return inventoryItem
    }
}
