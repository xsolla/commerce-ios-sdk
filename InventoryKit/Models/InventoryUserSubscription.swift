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

public struct InventoryUserSubscription
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Type of the item: `virtual_good`.
    public let type: String

    /// Type of the virtual item.
    public let virtualItemType: String

    /// Subscription name.
    public let name: String

    /// Subscription description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String?

    /// Unix Timestamp. Subscription expiration date. If the user hasn't got a subscription, the value is null.
    public let expiredAt: Date?

    /// Subscription status.
    ///
    /// Subscription can be in three statuses:
    /// * `none` - not bought.
    /// * `active` - subscription is active.
    /// * `expired` - subscription was purchased but expired.
    public let status: Status

    public enum Status: String
    {
        case none
        case active
        case expired
    }
}

extension InventoryUserSubscription
{
    init(fromAPIResponse apiResponseModel: GetUserSubscriptionsResponse.Item)
    {
        self.sku = apiResponseModel.sku
        self.type = apiResponseModel.type
        self.virtualItemType = apiResponseModel.virtualItemType
        self.name = apiResponseModel.name
        self.description = apiResponseModel.description
        self.imageUrl = apiResponseModel.imageUrl
        self.expiredAt = apiResponseModel.expiredAt
        self.status = Status(rawValue: apiResponseModel.status) ?? .none
    }
}
