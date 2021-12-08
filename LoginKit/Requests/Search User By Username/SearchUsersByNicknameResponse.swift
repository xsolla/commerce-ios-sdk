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

// swiftlint:disable nesting

import Foundation

struct SearchUsersByNicknameResponse: Decodable
{
    let offset: Int
    let totalCount: Int
    let users: [User]

    enum CodingKeys: String, CodingKey
    {
        case offset
        case totalCount = "total_count"
        case users
    }

    struct User: Codable
    {
        let avatar: String?
        let isMe: Bool
        let lastLogin: String
        let nickname: String
        let registered: String
        let tag: String?
        let userID: String

        enum CodingKeys: String, CodingKey
        {
            case avatar
            case isMe = "is_me"
            case lastLogin = "last_login"
            case nickname, registered, tag
            case userID = "user_id"
        }
    }
}
