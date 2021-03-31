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

// swiftlint:disable nesting

import Foundation
import XsollaSDKInventoryKit

struct InventoryListItem
{
    let sku: String
    let instanceId: String?
    let name: String
    let description: String?
    let groups: [Group]
    let type: ItemType
    let quantity: Int?
    let imageUrl: String?
    let remainingUses: Int?
    let virtualItemType: VirtualItemType?
    let detailedSubscriptionInfo: UserSubscription?
    
    init(inventoryKitItem item: InventoryItem)
    {
        self.sku = item.sku
        self.instanceId = item.instanceId
        self.name = item.name
        self.description = item.description
        self.groups = item.groups.map { Group(externalId: $0.externalId, name: $0.name) }
        self.type = ItemType(rawValue: item.type.rawValue) ?? .virtualGood
        self.quantity = item.quantity
        self.imageUrl = item.imageUrl
        self.remainingUses = item.remainingUses
        self.virtualItemType = VirtualItemType(rawValue: item.virtualItemType?.rawValue ?? "")
        self.detailedSubscriptionInfo = UserSubscription(inventoryKitUserSubscription: item.detailedSubscriptionInfo)
    }
}

extension InventoryListItem
{
    enum ItemType: String
    {
        case virtualGood = "virtual_good"
        case virtualCurrency = "virtual_currency"
    }
    
    enum VirtualItemType: String
    {
        case consumable = "consumable"
        case nonConsumable = "non_consumable"
        case nonRenewingSubscription = "non_renewing_subscription"
    }
    
    public struct Group
    {
        public let externalId: String
        public let name: String
    }
    
    struct UserSubscription
    {
        public let sku: String
        public let type: String
        public let virtualItemType: String
        public let name: String
        public let description: String?
        public let imageUrl: String?
        public let expiredAt: Date?
        public let status: Status
        
        public enum Status: String
        {
            case none
            case active
            case expired
        }
        
        init?(inventoryKitUserSubscription subscription: InventoryUserSubscription?)
        {
            guard let subscription = subscription else { return nil }
            
            self.sku = subscription.sku
            self.type = subscription.type
            self.virtualItemType = subscription.virtualItemType
            self.name = subscription.name
            self.description = subscription.description
            self.imageUrl = subscription.imageUrl
            self.expiredAt = subscription.expiredAt
            self.status = Status(rawValue: subscription.status.rawValue) ?? .none
        }
    }
}
