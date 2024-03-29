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

public struct StoreUserGame
{
    /// Game package name.
    public let name: String

    /// Game package description.
    public let itemDescription: String

    /// Image URL.
    public let imageURL: String

    /// Project ID.
    public let projectID: Int

    /// Unique key package ID.
    public let gameSku: String

    /// Unique DRM ID. Can be `steam`, `playstation`, `xbox`, `uplay`, `origin`, `drmfree`, `gog`, `epicgames`, `nintendo_eshop`, `discord_game_store`, `oculus`, `rockstar`, `viveport`, `stadia`
    public let drm: String

    /// Whether the game is in pre-order status or is not.
    public let isPreOrder: Bool
}
