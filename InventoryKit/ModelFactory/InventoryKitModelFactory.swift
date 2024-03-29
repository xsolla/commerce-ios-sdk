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

// swiftlint:disable line_length

import Foundation

protocol ModelFactoryProtocol
{
    func getInventoryItem(response: GetUserInventoryItemsResponse.Item) -> InventoryItem
    func getInventoryVirtualCurrencyBalances(response: GetUserVirtualCurrencyBalanceResponse) -> [InventoryVirtualCurrencyBalance]
    func getTimeLimitedItems(response: GetTimeLimitedItemsResponse) -> [TimeLimitedItem]
}

class InventoryKitModelFactory: ModelFactoryProtocol
{
    func getInventoryItem(response: GetUserInventoryItemsResponse.Item) -> InventoryItem
    {
        guard let itemType = InventoryItem.ItemType(rawValue: response.type) else
        {
            fatalError("Unsupported item type")
        }

        let attributes: [InventoryItemAttribute] = response.attributes.map
        { attribute in

            let values = attribute.values.map
            {
                InventoryItemAttribute.Value(externalId: $0.externalId, value: $0.value)
            }

            return InventoryItemAttribute(externalId: attribute.externalId, name: attribute.name, values: values)
        }

        let groups = response.groups.map { InventoryItemGroup(externalId: $0.externalId, name: $0.name) }

        return InventoryItem(instanceId: response.instanceId,
                             sku: response.sku,
                             type: itemType,
                             name: response.name,
                             quantity: response.quantity,
                             description: response.description,
                             imageUrl: response.imageUrl,
                             groups: groups,
                             attributes: attributes,
                             remainingUses: response.remainingUses,
                             virtualItemType: InventoryItem.VirtualItemType(rawValue: response.virtualItemType ?? ""),
                             detailedSubscriptionInfo: nil)
    }

    func getInventoryVirtualCurrencyBalances(response: GetUserVirtualCurrencyBalanceResponse) -> [InventoryVirtualCurrencyBalance]
    {
        response.items.map { getInventoryVirtualCurrencyBalance(response: $0) }
    }

    func getTimeLimitedItems(response: GetTimeLimitedItemsResponse) -> [TimeLimitedItem]
    {
        response.items.map { getInventoryUserSubscription(response: $0) }
    }

    // MARK: - Internal models

    func getInventoryVirtualCurrencyBalance(response: GetUserVirtualCurrencyBalanceResponse.Item) -> InventoryVirtualCurrencyBalance
    {
        InventoryVirtualCurrencyBalance(sku: response.sku,
                                        type: response.type,
                                        name: response.name,
                                        amount: response.amount,
                                        description: response.description,
                                        imageUrl: response.imageUrl)
    }

    func getInventoryUserSubscription(response: GetTimeLimitedItemsResponse.Item) -> TimeLimitedItem
    {
        TimeLimitedItem(sku: response.sku,
                                  type: response.type,
                                  virtualItemType: response.virtualItemType,
                                  name: response.name,
                                  description: response.description,
                                  imageUrl: response.imageUrl,
                                  expiredAt: response.expiredAt,
                                  status: TimeLimitedItem.Status(rawValue: response.status) ?? .none)
    }
}
