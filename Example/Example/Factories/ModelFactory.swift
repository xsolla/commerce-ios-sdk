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
    func createInventoryList(params: InventoryListBuildParams) -> InventoryList
    func createVirtualCurrencyList(params: VirtualCurrencyListBuildParams) -> VirtualCurrencyList
    func createVirtualItemsList(params: VirtualItemsListBuildParams) -> VirtualItemsList
    func createVirtualItemsActionHandler(params: VirtualItemsActionHandlerBuildParams) -> VirtualItemsActionHandler
    func createVirtualCurrencyBalanceFetcher(params: VirtualCurrencyBalanceFetcherBuildParams) -> VirtualCurrencyBalanceFetcher
    func createUserProfile(params: UserProfileBuildParams) -> UserProfile
    func createUserCharacter(params: UserCharacterBuildParams) -> UserCharacter
    func createSocialNetworksList(params: SocialNetworksListParams) -> SocialNetworksListProtocol
}

class ModelFactory: ModelFactoryProtocol
{
    func createInventoryList(params: InventoryListBuildParams) -> InventoryList
    {
        return InventoryList(dependencies: .init(loadStateListener: params.loadStateListener,
                                                 dataSource: params.dataSource,
                                                 xsollaSDK: self.params.xsollaSDK))
    }
    
    func createVirtualCurrencyList(params: VirtualCurrencyListBuildParams) -> VirtualCurrencyList
    {
        return VirtualCurrencyList(dependencies: .init(loadStateListener: params.loadStateListener,
                                                       dataSource: params.dataSource,
                                                       xsollaSDK: self.params.xsollaSDK))
    }
    
    func createVirtualItemsList(params: VirtualItemsListBuildParams) -> VirtualItemsList
    {
        return VirtualItemsList(dependencies: .init(loadStateListener: params.loadStateListener,
                                                    dataSource: params.dataSource,
                                                    xsollaSDK: self.params.xsollaSDK))
    }
    
    func createVirtualItemsActionHandler(params: VirtualItemsActionHandlerBuildParams) -> VirtualItemsActionHandler
    {
        return VirtualItemsActionHandler(dataSource: params.dataSource,
                                         viewController: params.viewController,
                                         virtualItemsList: params.virtualItemsList,
                                         store: params.store)
    }
    
    func createVirtualCurrencyBalanceFetcher(params: VirtualCurrencyBalanceFetcherBuildParams) -> VirtualCurrencyBalanceFetcher
    {
        return VirtualCurrencyBalanceFetcher(xsollaSDK: self.params.xsollaSDK)
    }
    
    func createUserProfile(params: UserProfileBuildParams) -> UserProfile
    {
        return UserProfile(dependencies: .init(asyncUtility: params.asyncUtility))
    }

    func createUserCharacter(params: UserCharacterBuildParams) -> UserCharacter
    {
        let asyncUtility = CharacterAsyncUtility(api: self.params.xsollaSDK,
                                                 projectId: params.projectId,
                                                 userDetailsProvider: params.userDetailsProvider)

        let dependencies = UserCharacter.Dependencies(asyncUtility: asyncUtility,
                                                      loadStateListener: params.loadStateListener,
                                                      customAttributesDataSource: params.customAttributesDataSource,
                                                      readonlyAttributesDataSource: params.readonlyAttributesDataSource)

        return UserCharacter(dependencies: dependencies)
    }
    
    func createSocialNetworksList(params: SocialNetworksListParams) -> SocialNetworksListProtocol
    {
        let socialNetworksList = SocialNetworksList()
        socialNetworksList.setup(socialNetworks: params.socialNetworks)
        
        return socialNetworksList
    }

    // MARK: - Initialization
    
    let params: Params
    
    init(params: Params)
    {
        self.params = params
    }
}

extension ModelFactory
{
    struct Params
    {
        let xsollaSDK: XsollaSDKProtocol
        let dataSourceFactory: DatasourceFactoryProtocol
    }
}

struct InventoryListBuildParams
{
    let loadStateListener: LoadStatable
    let dataSource: InventoryListDataSource
}

struct VirtualCurrencyListBuildParams
{
    let loadStateListener: LoadStatable
    let dataSource: VirtualCurrencyListDatasource
}

struct VirtualItemsListBuildParams
{
    let loadStateListener: LoadStatable
    let dataSource: VirtualItemsListDatasource
}

struct VirtualItemsActionHandlerBuildParams
{
    let dataSource: VirtualItemsListDatasource
    let viewController: VirtualItemsVCProtocol
    let virtualItemsList: VirtualItemsList
    let store: StoreProtocol
}

typealias VirtualCurrencyBalanceFetcherBuildParams = EmptyParams

struct UserCharacterBuildParams
{
    let projectId: Int
    let userDetailsProvider: UserProfileDetailsProvider
    let loadStateListener: LoadStatable
    let customAttributesDataSource: UserAttributesListDataSource
    let readonlyAttributesDataSource: UserAttributesListDataSource
}

struct SocialNetworksListParams
{
    let socialNetworks: [SocialNetwork]
}

struct UserProfileBuildParams
{
    let asyncUtility: LoginAsyncUtilityProtocol
}
