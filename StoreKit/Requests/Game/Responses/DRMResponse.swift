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

struct DRMResponse: Codable
{
    let sku: String
    let name: String
    let image: String
    let link: String?
    let redeemInstructionLink: String?
    let drmID: Int

    enum CodingKeys: String, CodingKey
    {
        case sku
        case name
        case image
        case link
        case redeemInstructionLink = "redeem_instruction_link"
        case drmID = "drm_id"
    }
}
