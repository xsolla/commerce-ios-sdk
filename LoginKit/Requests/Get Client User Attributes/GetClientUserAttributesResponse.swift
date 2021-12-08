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

// swiftlint:disable redundant_string_enum_value

import Foundation

typealias GetClientUserAttributesResponse = [UserAttributeResponse]

struct UserAttributeResponse: Decodable
{
    let key: String
    let permission: String?
    let value: String
    
    enum CodingKeys: String, CodingKey
    {
        case key = "key"
        case permission = "permission"
        case value = "value"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        permission = try container.decodeIfPresent(String.self, forKey: .permission)
        value = try container.decode(String.self, forKey: .value)
    }
}
