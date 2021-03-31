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

/// Item price.
public struct StoreItemPrice
{
    /// Discounted item price.
    public let amount: Double?

    /// Item price.
    public let amountWithoutDiscount: Double?

    /// Default purchase currency. Three-letter code per ISO 4217.
    public let currency: String?
}

extension StoreItemPrice
{
    init(fromAPIResponse response: StoreResponseCommon.Price)
    {
        self.amount = response.amount
        self.amountWithoutDiscount = response.amountWithoutDiscount
        self.currency = response.currency
    }

    init?(fromOptionalAPIResponse optionalResponse: StoreResponseCommon.Price?)
    {
        guard let response = optionalResponse else { return nil }

        self.amount = response.amount
        self.amountWithoutDiscount = response.amountWithoutDiscount
        self.currency = response.currency
    }
}
