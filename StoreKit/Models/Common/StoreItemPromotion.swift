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

/// Promotion settings in Store.
public struct StoreItemPromotion
{
    /// Promotion name that is displayed only in the list of promotions.
    public let name: String

    /// The date promotion starts.
    public let dateStart: String?

    /// The date promotion finishes.
    public let dateEnd: String?

    /// Promotion with a discount for the selected items in Store.
    public let discount: Discount

    /// Bonus promotion lets users get bonus items for buying promotional items.
    public let bonus: [Bonus]

    /// Limitations applied to the created promotion.
    public let limits: Limits?

    /// Promotion with a discount for the selected items in Store.
    public struct Discount
    {
        /// The discount amount provided by the promotion.
        public let percent: String?
        
        /// Discount percent value.
        public let value: String?
    }

    /// Bonus promotion lets users get bonus items for buying promotional items.
    public struct Bonus
    {
        /// Unique ID of promotional and bonus items that participate in promotions.
        public let sku: String
        
        /// Amount of promotional and bonus items.
        public let quantity: Int
    }

    /// Limitations applied to the created promotion.
    public struct Limits
    {
        /// Limitations applied to the use of promotions.
        public let perUser: LimitsPerUser
    }

    /// Limitations applied to the use of promotions.
    public struct LimitsPerUser
    {
        /// Whether to limit the number of times one user can use a promotion.
        public let available: Int
        
        /// Number of times one user can use a promotion.
        public let total: Int
    }
}
