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

public enum FriendsListType: String
{
    case friends = "friends"
    case friendRequested = "friend_requested"
    case friendRequestedBy = "friend_requested_by"
    case blocked = "blocked"
    case blockedBy = "blocked_by"
}

public enum FriendsListSortType: String
{
    case byNickname = "by_nickname"
    case byUpdated = "by_updated"
}

public enum FriendsListOrderType: String
{
    case asc = "asc"
    case desc = "desc"
}

public enum FriendsListUpdateAction: String
{
    case friendRequestAdd = "friend_request_add"
    case friendRequestCancel = "friend_request_cancel"
    case friendRequestApprove = "friend_request_approve"
    case friendRequestDeny = "friend_request_deny"
    case friendRemove = "friend_remove"
    case block = "block"
    case unblock = "unblock"
}
