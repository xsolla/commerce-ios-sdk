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
// swiftlint:disable type_name

import Foundation

protocol ModelFactoryProtocol
{
    func createInventoryList(params: InventoryListBuildParams) -> InventoryList
    func createVirtualCurrencyList(params: VirtualCurrencyListBuildParams) -> VirtualCurrencyList
    func createVirtualItemsList(params: VirtualItemsListBuildParams) -> VirtualItemsList
    func createVirtualItemsActionHandler(params: VirtualItemsActionHandlerBuildParams) -> VirtualItemsActionHandler
    func createVirtualCurrencyBalanceProvider(params: VirtualCurrencyBalanceProviderBuildParams) -> VirtualCurrencyBalanceProvider
    func createCurrentUserInfoProvider(params: CurrentUserInfoProviderBuildParams) -> CurrentUserInfoProvider
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
    
    func createVirtualCurrencyBalanceProvider(params: VirtualCurrencyBalanceProviderBuildParams) -> VirtualCurrencyBalanceProvider
    {
        return VirtualCurrencyBalanceProvider(xsollaSDK: self.params.xsollaSDK, projectId: params.projectId)
    }
    
    func createCurrentUserInfoProvider(params: CurrentUserInfoProviderBuildParams) -> CurrentUserInfoProvider
    {
        return CurrentUserInfoProvider(xsollaSDK: self.params.xsollaSDK)
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

struct VirtualCurrencyBalanceProviderBuildParams
{
    let projectId: Int
}

struct CurrentUserInfoProviderBuildParams
{
    static let empty = CurrentUserInfoProviderBuildParams()
}
