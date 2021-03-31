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

struct GetCurrentUserDetailsResponse: Decodable
{
    let ban: Ban?
    let birthday: Date?
    let connectionInformation: String?
    let country: String?
    let email: String?
    let externalId: String?
    let firstName: String?
    let gender: String?
    let groups: [Group]
    let id: String
    let lastLogin: Date
    let lastName: String?
    let name: String?
    let nickname: String?
    let phone: String?
    let picture: String?
    let registered: Date
    let tag: String?
    let username: String?
    
    enum CodingKeys: String, CodingKey
    {
        case ban = "ban"
        case birthday = "birthday"
        case connectionInformation = "connection_information"
        case country = "country"
        case email = "email"
        case externalId = "external_id"
        case firstName = "first_name"
        case gender = "gender"
        case groups = "groups"
        case id = "id"
        case lastLogin = "last_login"
        case lastName = "last_name"
        case name = "name"
        case nickname = "nickname"
        case phone = "phone"
        case picture = "picture"
        case registered = "registered"
        case tag = "tag"
        case username = "username"
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ban = try container.decodeIfPresent(Ban.self, forKey: .ban)
        connectionInformation = try container.decodeIfPresent(String.self, forKey: .connectionInformation)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        externalId = try container.decodeIfPresent(String.self, forKey: .externalId)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        groups = try container.decode([Group].self, forKey: .groups)
        id = try container.decode(String.self, forKey: .id)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        picture = try container.decodeIfPresent(String.self, forKey: .picture)
        tag = try container.decodeIfPresent(String.self, forKey: .tag)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        
        // INFO: [@r.mingazov] здесь вручную подставляется Date formatter,
        // потому что в ответе используются разные форматы дат
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        
        dateFormatter.dateFormat = "YYYY-MM-DD"
        birthday = try container.decodeDateIfPresent(dateFormatter: dateFormatter, key: .birthday)
        
        dateFormatter.dateFormat = "YYYY-MM-DD'T'hh:mm:ssZ"
        lastLogin = try container.decodeDate(dateFormatter: dateFormatter, key: .lastLogin)
        registered = try container.decodeDate(dateFormatter: dateFormatter, key: .registered)
    }
}

extension GetCurrentUserDetailsResponse
{
    struct Ban: Decodable
    {
        let dateFrom: Date
        let dateTo: Date?
        let reason: String?
        
        enum CodingKeys: String, CodingKey
        {
            case dateFrom = "date_from"
            case dateTo = "date_to"
            case reason = "reason"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            dateFrom = try container.decode(Date.self, forKey: .dateFrom)
            dateTo = try container.decodeIfPresent(Date.self, forKey: .dateTo)
            reason = try container.decodeIfPresent(String.self, forKey: .reason)
        }
    }
}

extension GetCurrentUserDetailsResponse
{
    struct Group: Decodable
    {
        let id: Int
        let isDefault: Bool
        let isDeletable: Bool
        let name: String
        
        enum CodnigKeys: String, CodingKey
        {
            case id = "id"
            case isDefault = "is_default"
            case isDeletable = "is_deletable"
            case name = "name"
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodnigKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            isDefault = try container.decode(Bool.self, forKey: .isDefault)
            isDeletable = try container.decode(Bool.self, forKey: .isDeletable)
            name = try container.decode(String.self, forKey: .name)
        }
    }
}

private extension KeyedDecodingContainer
{
    func decodeDateIfPresent(dateFormatter: DateFormatter, key: Self.Key) throws -> Date?
    {
        guard let dateString = try decodeIfPresent(String.self, forKey: key) else { return nil }
        
        guard let date = dateFormatter.date(from: dateString)
        else
        {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Cannot parse date from string \(dateString)")
        }
        
        return date
    }
    
    func decodeDate(dateFormatter: DateFormatter, key: Self.Key) throws -> Date
    {
        let dateString = try decode(String.self, forKey: key)
        
        guard let date = dateFormatter.date(from: dateString)
        else
        {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Cannot parse date from string \(dateString)")
        }
        
        return date
    }
}
