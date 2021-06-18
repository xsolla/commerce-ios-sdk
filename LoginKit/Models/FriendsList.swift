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


/// Information about user friends
public struct FriendsList
{
    /// Value of the `after` parameter that should be passed while requesting this call for the next time.
    public let nextPage: String?

    /// URL of the request for using this call for the next time.
    public let nextPageURL: URL?

    /// Friends details.
    public let relationships: [Relationship]
}

extension FriendsList
{
    /// Friends details
    public struct Relationship
    {
        /// Status of the current user depending on the requested friend.
        public let incomingStatus: Status

        /// Status of the requested friend depending on the current user.
        public let outgoingStatus: Status

        /// Date of the latest action of adding a friend to the friend list or banning them in seconds.
        public let updated: Date

        /// User details.
        public let user: User
    }
}

extension FriendsList.Relationship
{
    public enum Status
    {
        case friend
        case friendRequested
        case blocked
        case none
    }

    /// User details.
    public struct User
    {
        /// User ID.
        public let id: String

        /// User name in a social network.
        public let name: String?

        /// User nickname.
        public let nickname: String?

        /// Link to the user profile picture.
        public let pictureURL: URL?

        /// User presence status.
        public let presenceStatus: PresenceStatus

        /// User tag without \"#\" at the beginning.
        /// Can have no unique value and can be used in the [Search users by nickname](https://developers.xsolla.com/login-api/user-account/managed-by-client/user-friends/search-users-by-nickname) call.
        public let tag: String?
    }
}

extension FriendsList.Relationship.User
{
    public enum PresenceStatus
    {
        case online
        case offline
    }
}

// MARK: - Initializations

extension FriendsList
{
    init(fromResponse response: GetCurrentUserFriendsResponse)
    {
        nextPage = response.nextAfter
        relationships = response.relationships.map { Relationship(fromResponse: $0) }

        if let nextUrlString = response.nextURL
        {
            nextPageURL = URL(string: nextUrlString)
        }
        else
        {
            nextPageURL = nil
        }
    }
}

extension FriendsList.Relationship
{
    init(fromResponse response: GetCurrentUserFriendsResponse.Relationship)
    {
        incomingStatus = Status(rawValue: response.statusIncoming)
        outgoingStatus = Status(rawValue: response.statusOutgoing)
        updated = response.updated
        user = User(fromResponse: response.user)
    }
}

extension FriendsList.Relationship.Status
{
    init(rawValue: String)
    {
        switch rawValue
        {
            case "friend": self = .friend
            case "friend_requested": self = .friendRequested
            case "blocked": self = .blocked
            default: self = .none
        }
    }
}

extension FriendsList.Relationship.User
{
    init(fromResponse response: GetCurrentUserFriendsResponse.Relationship.UserDetail)
    {
        id = response.id
        name = response.name
        nickname = response.nickname
        presenceStatus = PresenceStatus(rawValue: response.presence)
        tag = response.tag

        if let pictureUrlString = response.picture
        {
            pictureURL = URL(string: pictureUrlString)
        }
        else
        {
            pictureURL = nil
        }
    }
}

extension FriendsList.Relationship.User.PresenceStatus
{
    init(rawValue: String)
    {
        switch rawValue
        {
            case "online": self = .online
            default: self = .offline
        }
    }
}
