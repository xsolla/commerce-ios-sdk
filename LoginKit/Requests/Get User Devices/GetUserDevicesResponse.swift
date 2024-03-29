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

typealias GetUserDevicesResponse = [UserDeviceResponse]

struct UserDeviceResponse: Decodable
{
    let device: String
    let id: Int
    let lastUsedAt: Date
    let type: String
    
    enum CodingKeys: String, CodingKey
    {
        case device = "device"
        case id = "id"
        case lastUsedAt = "last_used_at"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        device = try container.decode(String.self, forKey: .device)
        id = try container.decode(Int.self, forKey: .id)
        lastUsedAt = try container.decode(Date.self, forKey: .lastUsedAt)
        type = try container.decode(String.self, forKey: .type)
    }
}
