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

/// Item group.
public struct StoreItemGroup
{
    /// External group ID.
    public let externalId: String

    /// Group name.
    public let name: String

    /// Group description.
    public let description: String?

    /// Image URL.
    public let imageUrl: String?

    /// Defines arrangement order.
    public let order: Int

    /// Group nesting level.
    public let level: Int

    /// Child groups.
    public let children: [StoreItemGroup]?

    /// Parent external group ID.
    public let parentExternalId: String?
}

/// Item group's short presentation.
public struct StoreItemGroupShort
{
    /// External group ID.
    public let externalId: String

    /// Group name.
    public let name: String
}

extension StoreItemGroup
{
    init(fromAPIResponse response: GetItemGroupsResponse.Group)
    {
        externalId = response.externalId
        name = response.name
        description = response.description
        imageUrl = response.imageUrl
        order = response.order
        level = response.level
        children = response.children?.map { StoreItemGroup(fromAPIResponse: $0) }
        parentExternalId = response.parentExternalId
    }
}
