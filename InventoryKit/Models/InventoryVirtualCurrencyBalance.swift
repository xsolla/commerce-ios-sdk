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

public struct InventoryVirtualCurrencyBalance
{
    /// Unique item ID. The SKU may only contain lowercase Latin alphanumeric characters, periods, dashes, and underscores.
    public let sku: String

    /// Type of the item: `virtual_good`, `virtual_currency`, `bundle`.
    public let type: String

    /// Item name.
    public let name: String

    /// Item quantity.
    public let amount: Int

    /// Item description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String?
}

extension InventoryVirtualCurrencyBalance
{
    init(fromAPIResponse apiResponseModel: GetUserVirtualCurrencyBalanceResponse.Item)
    {
        self.sku = apiResponseModel.sku
        self.type = apiResponseModel.type
        self.name = apiResponseModel.name
        self.amount = apiResponseModel.amount
        self.description = apiResponseModel.description
        self.imageUrl = apiResponseModel.imageUrl
    }
}
