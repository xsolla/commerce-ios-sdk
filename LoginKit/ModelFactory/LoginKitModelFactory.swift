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

// swiftlint:disable line_length

import Foundation

protocol ModelFactoryProtocol
{
    func getAccessTokenInfo(response: GenerateJWTResponse) -> AccessTokenInfo
    func getUserProfileDetails(response: GetCurrentUserDetailsResponse) -> UserProfileDetails
    func getUserProfileDetails(response: UpdateCurrentUserDetailsResponse) -> UserProfileDetails
    func getDevicesInfo(response: GetUserDevicesResponse) -> [DeviceInfo]
    func getUserPublicProfile(response: GetUserPublicProfileResponse) -> UserPublicProfile
    func getFriendsList(response: GetCurrentUserFriendsResponse) -> FriendsList
    func getLinksForSocialAuth(response: GetLinksForSocialAuthResponse) -> LinksForSocialAuth
    func getUserSocialNetworkInfos(response: GetLinkedNetworksResponse) -> [UserSocialNetworkInfo]
    func getSocialNetworkFriendsList(response: GetSocialNetworkFriendsResponse) -> SocialNetworkFriendsList
    func getSearchUsersByNicknameResult(response: SearchUsersByNicknameResponse) -> SearchUsersByNicknameResult
    func getUserAttributes(response: [UserAttributeResponse]) -> [UserAttribute]
}

class LoginKitModelFactory: ModelFactoryProtocol
{
    func getAccessTokenInfo(response: GenerateJWTResponse) -> AccessTokenInfo
    {
        AccessTokenInfo(accessToken: response.accessToken,
                        expiresIn: response.expiresIn,
                        refreshToken: response.refreshToken,
                        tokenType: response.tokenType)
    }

    func getUserProfileDetails(response: GetCurrentUserDetailsResponse) -> UserProfileDetails
    {
        let banDetails: UserProfileDetails.BanDetails? =
        {
            guard let banResponse = response.ban else { return nil }

            return UserProfileDetails.BanDetails(dateFrom: banResponse.dateFrom,
                                                 dateTo: banResponse.dateTo,
                                                 reason: banResponse.reason)
        }()

        let groups = response.groups.map
        {
            UserProfileDetails.Group(id: $0.id, isDefault: $0.isDefault, isDeletable: $0.isDeletable, name: $0.name)
        }

        return UserProfileDetails(ban: banDetails,
                                  birthday: response.birthday,
                                  connectionInformation: response.connectionInformation,
                                  country: response.country,
                                  email: response.email,
                                  externalId: response.externalId,
                                  firstName: response.firstName,
                                  gender: UserProfileDetails.Gender(rawValue: response.gender ?? ""),
                                  groups: groups,
                                  id: response.id,
                                  lastLogin: response.lastLogin,
                                  lastName: response.lastName,
                                  name: response.name,
                                  nickname: response.nickname,
                                  phone: response.phone,
                                  picture: response.picture,
                                  registered: response.registered,
                                  tag: response.tag,
                                  username: response.username,
                                  isAnonymous: response.isAnonymous,
                                  isLastEmailConfirmed: response.isLastEmailConfirmed,
                                  isUserActive: response.isUserActive)
    }

    func getUserProfileDetails(response: UpdateCurrentUserDetailsResponse) -> UserProfileDetails
    {
        let banDetails: UserProfileDetails.BanDetails? =
        {
            guard let banResponse = response.ban else { return nil }

            return UserProfileDetails.BanDetails(dateFrom: banResponse.dateFrom,
                                                 dateTo: banResponse.dateTo,
                                                 reason: banResponse.reason)
        }()

        let groups = response.groups.map
        {
            UserProfileDetails.Group(id: $0.id, isDefault: $0.isDefault, isDeletable: $0.isDeletable, name: $0.name)
        }

        return UserProfileDetails(ban: banDetails,
                                  birthday: response.birthday,
                                  connectionInformation: response.connectionInformation,
                                  country: response.country,
                                  email: response.email,
                                  externalId: response.externalId,
                                  firstName: response.firstName,
                                  gender: UserProfileDetails.Gender(rawValue: response.gender ?? ""),
                                  groups: groups,
                                  id: response.id,
                                  lastLogin: response.lastLogin,
                                  lastName: response.lastName,
                                  name: response.name,
                                  nickname: response.nickname,
                                  phone: response.phone,
                                  picture: response.picture,
                                  registered: response.registered,
                                  tag: response.tag,
                                  username: response.username,
                                  isAnonymous: response.isAnonymous,
                                  isLastEmailConfirmed: response.isLastEmailConfirmed,
                                  isUserActive: response.isUserActive)
    }

    func getFriendsList(response: GetCurrentUserFriendsResponse) -> FriendsList
    {
        FriendsList(nextPage: response.nextAfter,
                    nextPageURL: response.nextURL.flatMap { URL(string: $0) },
                    relationships: response.relationships.map { FriendsList.Relationship(fromResponse: $0) })
    }

    func getLinksForSocialAuth(response: GetLinksForSocialAuthResponse) -> LinksForSocialAuth
    {
        response.map { LinksForSocialAuthElement(authURL: $0.authURL, provider: $0.provider) }
    }

    func getUserSocialNetworkInfos(response: GetLinkedNetworksResponse) -> [UserSocialNetworkInfo]
    {
        response.map { getUserSocialNetworkInfo(response: $0) }
    }

    func getUserAttributes(response: [UserAttributeResponse]) -> [UserAttribute]
    {
        response.map { getUserAttribute(response: $0) }
    }

    func getSocialNetworkFriendsList(response: GetSocialNetworkFriendsResponse) -> SocialNetworkFriendsList
    {
        let accountsData = response.data.map
        {
            SocialNetworkFriendsList.SocialAccountData(avatar: $0.avatar,
                                                       name: $0.name,
                                                       platform: $0.platform,
                                                       tag: $0.tag,
                                                       userId: $0.userId,
                                                       loginId: $0.loginId)
        }

        return SocialNetworkFriendsList(accountsData: accountsData,
                                        limit: response.limit,
                                        offset: response.offset,
                                        platform: response.platform,
                                        totalCount: response.totalCount,
                                        withLoginId: response.withLoginId)
    }

    func getDevicesInfo(response: GetUserDevicesResponse) -> [DeviceInfo]
    {
        response.map { getDeviceInfo(response: $0) }
    }

    func getSearchUsersByNicknameResult(response: SearchUsersByNicknameResponse) -> SearchUsersByNicknameResult
    {
        SearchUsersByNicknameResult(offset: response.offset,
                                    totalCount: response.totalCount,
                                    users: response.users.map { getSearchUsersByNicknameResultUser(response: $0) })
    }

    func getUserPublicProfile(response: GetUserPublicProfileResponse) -> UserPublicProfile
    {
        UserPublicProfile(avatar: response.avatar,
                          lastLogin: response.lastLogin,
                          nickname: response.nickname,
                          registered: response.registered,
                          tag: response.tag,
                          userID: response.userID)
    }

    // MARK: - Internal models

    func getFriendsListRelationship(response: GetCurrentUserFriendsResponse.Relationship) -> FriendsList.Relationship
    {
        FriendsList.Relationship(incomingStatus: FriendsList.Relationship.Status(rawValue: response.statusIncoming),
                                 outgoingStatus: FriendsList.Relationship.Status(rawValue: response.statusOutgoing),
                                 updated: response.updated,
                                 user: FriendsList.Relationship.User(fromResponse: response.user))
    }

    func getFriendsListRelationshipUser(response: GetCurrentUserFriendsResponse.Relationship.UserDetail) -> FriendsList.Relationship.User
    {
        FriendsList.Relationship.User(id: response.id,
                                      name: response.name,
                                      nickname: response.nickname,
                                      pictureURL: response.picture.flatMap { URL(string: $0) },
                                      presenceStatus: FriendsList.Relationship.User.PresenceStatus(rawValue: response.presence),
                                      tag: response.tag)
    }

    func getSearchUsersByNicknameResultUser(response: SearchUsersByNicknameResponse.User) -> SearchUsersByNicknameResult.User
    {
        SearchUsersByNicknameResult.User(avatar: response.avatar,
                                         isMe: response.isMe,
                                         lastLogin: response.lastLogin,
                                         nickname: response.nickname,
                                         registered: response.registered,
                                         tag: response.tag,
                                         userID: response.userID)
    }

    func getUserAttribute(response: UserAttributeResponse) -> UserAttribute
    {
        UserAttribute(key: response.key, value: response.value, permission: response.permission)
    }

    func getUserSocialNetworkInfo(response: SocialNetworkResponse) -> UserSocialNetworkInfo
    {
        UserSocialNetworkInfo(userFullName: response.fullName,
                              userNickname: response.nickname,
                              userPictureURL: response.picture.flatMap { URL(string: $0) },
                              socialNetworkName: response.provider,
                              socialNetworkId: response.socialId)
    }

    func getDeviceInfo(response: UserDeviceResponse) -> DeviceInfo
    {
        DeviceInfo(modelName: response.device,
                   xsollaDeviceId: response.id,
                   lastUsedAt: response.lastUsedAt,
                   type: response.type)
    }
}
