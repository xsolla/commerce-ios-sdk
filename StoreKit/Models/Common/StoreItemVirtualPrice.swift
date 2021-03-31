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

/// Virtual item price in virtual currency.
public struct StoreItemVirtualPrice
{
    /// Discounted item price in virtual currency.
    public let amount: Int?

    /// Item price.
    public let amountWithoutDiscount: Int?

    /// Virtual currency item SKU.
    public let sku: String

    /// Whether the price is default for an item.
    public let isDefault: Bool

    /// Image URL.
    public let imageUrl: String?

    /// Virtual currency name.
    public let name: String

    /// Virtual currency type.
    public let type: String

    /// Virtual currency description.
    public let description: String?
}

extension StoreItemVirtualPrice
{
    init(fromAPIResponse response: StoreResponseCommon.VirtualPrice)
    {
        self.amount = response.amount
        self.amountWithoutDiscount = response.amountWithoutDiscount
        self.sku = response.sku
        self.isDefault = response.isDefault
        self.imageUrl = response.imageUrl
        self.name = response.name
        self.type = response.type
        self.description = response.description
    }

    init?(fromOptionalAPIResponse optionalResponse: StoreResponseCommon.VirtualPrice?)
    {
        guard let response = optionalResponse else { return nil }

        self.amount = response.amount
        self.amountWithoutDiscount = response.amountWithoutDiscount
        self.sku = response.sku
        self.isDefault = response.isDefault
        self.imageUrl = response.imageUrl
        self.name = response.name
        self.type = response.type
        self.description = response.description
    }
}
