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

struct UserGameResponse: Codable
{
    let name: String
    let itemDescription: String
    let imageURL: String
    let projectID: Int
    let gameSku: String
    let drm: String
    let isPreOrder: Bool

    enum CodingKeys: String, CodingKey
    {
        case name
        case itemDescription = "description"
        case imageURL = "image_url"
        case projectID = "project_id"
        case gameSku = "game_sku"
        case drm
        case isPreOrder = "is_pre_order"
    }
}
