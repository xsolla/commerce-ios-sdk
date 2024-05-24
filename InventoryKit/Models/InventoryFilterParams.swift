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

public class InventoryFilterParams
{
    /// Limit for the number of elements on the page. The maximum number of elements on a page is 50.
    public let limit: Int?

    /// Number of the element from which the list is generated (the count starts from 0).
    public let offset: Int?
    
    /// Publishing platform the user plays on.
    public let platform: String?
    
    public init(limit: Int?, offset: Int?, platform: String?) 
    {
        self.limit = limit
        self.offset = offset
        self.platform = platform
    }
    
    static public var empty: InventoryFilterParams
    {
        InventoryFilterParams(limit: nil, offset: nil, platform: nil)
    }
}
