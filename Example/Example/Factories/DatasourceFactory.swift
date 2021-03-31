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
import XsollaSDKStoreKit

protocol DatasourceFactoryProtocol
{
    func createInventoryListDatasource(params: InventoryListDatasourceBuildParams) -> InventoryListDataSource
    func createVirtualCurrencyListDatasource(params: VirtualCurrencyListDatasourceBuildParams) -> VirtualCurrencyListDatasource
    func createVirtualCurrencyListGroupDataSource(params: VirtualCurrencyListGroupDataSourceBuildParams) -> VirtualCurrencyListGroupDataSource
    func createVirtualItemsListDatasource(params: VirtualItemsListDatasourceBuildParams) -> VirtualItemsListDatasource
    func createVirtualItemsListGroupDataSource(params: VirtualItemsListGroupDataSourceBuildParams) -> VirtualItemsListGroupDataSource
    func createInventoryListGroupDataSource(params: InventoryListGroupDataSourceBuildParams) -> InventoryListGroupDataSource
    func createBundlePreviewDataSource(params: BundlePreviewDataSourceBuildParams) -> BundlePreviewDataSource
}

class DatasourceFactory: DatasourceFactoryProtocol
{
    func createInventoryListDatasource(params: InventoryListDatasourceBuildParams) -> InventoryListDataSource
    {
        return InventoryListDataSource(dependencies: .init(dataSourceFactory: self))
    }
    
    func createVirtualCurrencyListDatasource(params: VirtualCurrencyListDatasourceBuildParams) -> VirtualCurrencyListDatasource
    {
        return VirtualCurrencyListDatasource(dependencies: .init(dataSourceFactory: self))
    }
    
    func createVirtualCurrencyListGroupDataSource(params: VirtualCurrencyListGroupDataSourceBuildParams) -> VirtualCurrencyListGroupDataSource
    {
        let dataSource = VirtualCurrencyListGroupDataSource(groupIndex: params.groupIndex,
                                                            dataSource: params.dataSource,
                                                            priceHelper: self.params.priceHelper)
        dataSource.itemActionHandler = params.actionHandler
        
        return dataSource
    }
    
    func createVirtualItemsListDatasource(params: VirtualItemsListDatasourceBuildParams) -> VirtualItemsListDatasource
    {
        return VirtualItemsListDatasource(dependencies: .init(dataSourceFactory: self))
    }
    
    func createVirtualItemsListGroupDataSource(params: VirtualItemsListGroupDataSourceBuildParams) -> VirtualItemsListGroupDataSource
    {
        let dataSource = VirtualItemsListGroupDataSource(groupIndex: params.groupIndex,
                                                         dataSource: params.dataSource,
                                                         priceHelper: self.params.priceHelper)
        
        dataSource.itemActionHandler = params.actionHandler
        
        return dataSource
    }
    
    func createInventoryListGroupDataSource(params: InventoryListGroupDataSourceBuildParams) -> InventoryListGroupDataSource
    {
        let dataSource = InventoryListGroupDataSource(groupIndex: params.groupIndex,
                                                      dataSource: params.dataSource)
        
        dataSource.itemActionHandler = params.actionHandler
    
        return dataSource
    }
    
    func createBundlePreviewDataSource(params: BundlePreviewDataSourceBuildParams) -> BundlePreviewDataSource
    {
        let dataSource = BundlePreviewDataSource(bundle: params.bundle, priceHelper: self.params.priceHelper)
        
        return dataSource
    }
    
    // MARK: - Initialization
    
    let params: Params
    
    init(params: Params)
    {
        self.params = params
    }
}

extension DatasourceFactory
{
    struct Params
    {
        let priceHelper: ItemPriceHelperProtocol
    }
}

typealias InventoryListDatasourceBuildParams = EmptyParams
typealias VirtualCurrencyListDatasourceBuildParams = EmptyParams
typealias VirtualItemsListDatasourceBuildParams = EmptyParams

struct VirtualCurrencyListGroupDataSourceBuildParams
{
    let groupIndex: VirtualCurrencyListDatasource.GroupIndex
    let dataSource: VirtualCurrencyListDataSourceProtocol
    let actionHandler: VirtualCurrencyListGroupDataSource.ActionHandler?
}

struct VirtualItemsListGroupDataSourceBuildParams
{
    let groupIndex: VirtualItemsListDatasource.GroupIndex
    let dataSource: VirtualItemsListDataSourceProtocol
    let actionHandler: VirtualItemsListGroupDataSource.ActionHandler?
}

struct InventoryListGroupDataSourceBuildParams
{
    let groupIndex: InventoryListDataSource.GroupIndex
    let dataSource: InventoryListDataSource
    let actionHandler: InventoryListGroupDataSource.ActionHandler?
}

struct BundlePreviewDataSourceBuildParams
{
    let bundle: StoreBundle
}
