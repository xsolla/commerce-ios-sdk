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

/// Limitations applied to the created item.
public struct StoreItemLimits
{
    /// Limitations applied to the use of promotions.
    public let perUser: LimitsPerUser

    public struct LimitsPerUser
    {
        /// Whether to limit the number of times one user can buy an item.
        public let available: Int

        /// Number of times one user can buy an item.
        public let total: Int

        /// Regular limit refresh schedule.
        public let recurrentSchedule: RecurrentSchedule

        public struct RecurrentSchedule
        {
            /// Refresh period type.
            public let intervalType: String

            /// Next refresh date.
            public let resetNextDate: Int
        }
    }
}
