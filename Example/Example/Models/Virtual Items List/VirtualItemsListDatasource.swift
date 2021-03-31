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

import UIKit
import XsollaSDKStoreKit
import XsollaSDKInventoryKit

protocol VirtualItemsListDataSourceProtocol: AnyObject
{
    func getGroups() -> [VirtualItemsListDatasource.GroupInfo]
    func numberOfItems(in group: Int) -> Int
    func getItem(at index: Int, in group: VirtualItemsListDatasource.GroupIndex) -> VirtualItemsListDatasource.Item
    func getGroupDatasource(for groupIndex: VirtualItemsListDatasource.GroupIndex) -> TableViewDataSource
}

class VirtualItemsListDatasource
{
    typealias Item = VirtualItemsListItem
    typealias ActionHandler = ((VirtualItemsListItemAction, Item) -> Void)
    typealias GroupInfo = (index: GroupIndex, name: GroupName)
    typealias GroupName = String
    typealias GroupIndex = Int
    private typealias BoxedItem = Box<Item>
 
    var itemActionHandler: ActionHandler?
    
    private struct Group
    {
        let name: String
        var items: [BoxedItem]
    }
    
    private let dependencies: Dependencies
    private var groups = [Group]()
    private var dataSources = [TableViewDataSource]()
    private(set) var bundles = [String: StoreBundle]()
    
    func setup(bundles: [StoreBundle], items: [StoreVirtualItem], inventory: [InventoryItem])
    {
        self.bundles = bundles.mapToDictionary(keyPath: \.sku)
        
        let combinedBoxedItems =
            getCombinedBoxedItems(bundles: bundles, items: items, usingInventory: inventory).sorted(by: \.value.name)
        
        processBoxedItems(combinedBoxedItems)
        setupDataSources()
    }
    
    private func getCombinedBoxedItems(bundles: [StoreBundle],
                                       items: [StoreVirtualItem],
                                       usingInventory inventory: [InventoryItem]) -> [BoxedItem]
    {
        let inventorySkus = inventory.mapDistinctValue(keyPath: \.sku)
        
        let boxedBundleItems = bundles.reduce(into: [BoxedItem]())
        { result, bundle in
            
            guard let boxedItem = boxedItem(fromBundle: bundle, inventorySKUs: inventorySkus) else { return }
            
            result.append(boxedItem)
        }
        
        let boxedVirtualItems = items.reduce(into: [BoxedItem]())
        { result, item in
            
            guard let boxedItem = boxedItem(fromItem: item, inventorySKUs: inventorySkus) else { return }
            
            result.append(boxedItem)
        }
        
        var combinedBoxedItems = [BoxedItem]()
        combinedBoxedItems.append(contentsOf: boxedBundleItems)
        combinedBoxedItems.append(contentsOf: boxedVirtualItems)
        
        return combinedBoxedItems
    }
    
    private func boxedItem(fromBundle bundle: StoreBundle, inventorySKUs: [String]) -> BoxedItem?
    {
        guard let type = ItemType(rawValue: bundle.type) else { return nil }
        
        let item = Item(sku: bundle.sku,
                        name: bundle.name,
                        groups: bundle.groups,
                        attributes: bundle.attributes,
                        type: type,
                        description: bundle.description,
                        imageUrl: bundle.imageUrl,
                        isFree: bundle.isFree,
                        price: bundle.price,
                        totalContentPrice: bundle.totalContentPrice,
                        virtualPrices: bundle.virtualPrices,
                        inventoryOptions: nil,
                        existsInInventory: inventorySKUs.contains(bundle.sku),
                        virtualItemType: nil)
        
        return BoxedItem(value: item)
    }
    
    private func boxedItem(fromItem item: StoreVirtualItem, inventorySKUs: [String]) -> BoxedItem?
    {
        guard let type = ItemType(rawValue: item.type) else { return nil }
        
        let item = Item(sku: item.sku,
                        name: item.name,
                        groups: item.groups,
                        attributes: item.attributes,
                        type: type,
                        description: item.description,
                        imageUrl: item.imageUrl,
                        isFree: item.isFree,
                        price: item.price,
                        totalContentPrice: nil,
                        virtualPrices: item.virtualPrices,
                        inventoryOptions: item.inventoryOptions,
                        existsInInventory: inventorySKUs.contains(item.sku),
                        virtualItemType: VirtualItemType(rawValue: item.virtualItemType))
        
        return BoxedItem(value: item)
    }
    
    private func processBoxedItems(_ inputItems: [BoxedItem])
    {
        groups = []
        
        var allGroup = [BoxedItem]()
        var groupsDictionary = [String: [BoxedItem]]()
        
        for boxedItem in inputItems
        {
            allGroup.append(boxedItem)
            
            // Groupped items
            for name in getUniqueGroupNames(from: boxedItem.value)
            {
                var collection = groupsDictionary[name] ?? .init()
                collection.append(boxedItem)
                groupsDictionary[name] = collection
            }
        }
        
        let groupsArray: [Group] = groupsDictionary
            .map { Group(name: $0, items: $1) }
            .sorted { $0.name < $1.name }
        
        self.groups.append(Group(name: L10n.Common.Tabbar.Tab.all, items: allGroup))
        self.groups.append(contentsOf: groupsArray)
    }
    
    private func setupDataSources()
    {
        let factory = self.dependencies.dataSourceFactory
        
        self.dataSources = self.groups.enumerated().map
        {
            let params = VirtualItemsListGroupDataSourceBuildParams(groupIndex: $0.offset, dataSource: self)
            { [weak self] action, item in
                
                self?.itemActionHandler?(action, item)
            }
            
            let dataSource = factory.createVirtualItemsListGroupDataSource(params: params)
            
            return dataSource
        }
    }
    
    private func getUniqueGroupNames(from item: Item) -> Set<GroupName>
    {
        item.groups.reduce(into: Set<GroupName>()) { $0.insert($1.name) }
    }
    
    private lazy var dateFormatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter
    }()
    
    init(dependencies: Dependencies)
    {
        self.dependencies = dependencies
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
    
    struct Dependencies
    {
        let dataSourceFactory: DatasourceFactoryProtocol
    }
}

extension VirtualItemsListDatasource: VirtualItemsListDataSourceProtocol
{
    func getGroupDatasource(for groupIndex: GroupIndex) -> TableViewDataSource
    {
        guard groups.hasIndex(groupIndex) else { fatalError("Group index is out of bounds") }

        return dataSources[groupIndex]
    }
    
    func numberOfItems(in groupIndex: Int) -> Int
    {
        guard groups.hasIndex(groupIndex) else { fatalError("Group index is out of bounds") }
        
        return groups[groupIndex].items.count
    }
    
    func getItem(at itemIndex: Int, in groupIndex: GroupIndex) -> Item
    {
        guard groups.hasIndex(groupIndex) else { fatalError("Group index is out of bounds") }
        guard groups[groupIndex].items.hasIndex(itemIndex) else { fatalError("Item index is out of bounds") }
        
        return groups[groupIndex].items[itemIndex].value
    }
    
    func getGroups() -> [GroupInfo]
    {
        groups.enumerated().map { (index: $0, name: $1.name) }
    }
}
