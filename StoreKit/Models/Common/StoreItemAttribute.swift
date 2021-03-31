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

/// Item's attribute and its value. Can be used for catalog filtering.
public struct StoreItemAttribute
{
    /// Unique attribute ID. `externalId` may only contain lowercase Latin alphanumeric characters, dashes, and underscores.
    public let externalId: String

    /// Name of the attribute.
    public let name: String

    /// Values of the attribute.
    public let values: [Value]

    /// Item attribute's value
    public struct Value
    {
        /// Unique value ID. `externalId` may only contain lowercase Latin alphanumeric characters, dashes and underscores.
        public let externalId: String

        /// Value of the attribute.
        public let value: String
    }
}

extension StoreItemAttribute
{
    init(fromAPIResponse response: StoreResponseCommon.Attribute)
    {
        self.externalId = response.externalId
        self.name = response.name
        self.values = response.values.map { Value(externalId: $0.externalId, value: $0.value) }
    }
}
