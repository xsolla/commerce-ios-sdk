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

public struct StoreFilterParams
{
    /// Limit for the number of elements on the page.
    public let limit: Int?

    /// Number of the element from which the list is generated (the count starts from 0).
    public let offset: Int?

    /// Response language. Two-letter lowercase language code per ISO 639-1.
    public let locale: String?

    /// The list of additional fields. These fields will be in a response if you send it in a request.
    ///
    /// Available fields:
    /// * `media_list`
    /// * `order`
    /// * `long_description`.
    public let additionalFields: [String]?

    /// Country to calculate regional prices and restrictions for a catalog. Two-letter uppercase country code per ISO 3166-1 alpha-2.
    /// If you don't specify the country explicitly, it will be calculated based on the user's IP address.
    public let country: String?

    public init(limit: Int?, offset: Int?, locale: String?, additionalFields: [String]?, country: String?)
    {
        self.limit = limit
        self.offset = offset
        self.locale = locale
        self.additionalFields = additionalFields
        self.country = country
    }

    static public var empty: StoreFilterParams
    {
        StoreFilterParams(limit: nil, offset: nil, locale: nil, additionalFields: nil, country: nil)
    }
}
