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

// swiftlint:disable line_length

protocol VirtualCurrencyListDataSourceProtocol: AnyObject
{
    func getGroups() -> [VirtualCurrencyListDatasource.GroupInfo]
    func numberOfItems(in group: Int) -> Int
    func getItem(at index: Int, in group: VirtualCurrencyListDatasource.GroupIndex) -> VirtualCurrencyListDatasource.Item
    func getGroupDatasource(for groupIndex: VirtualCurrencyListDatasource.GroupIndex) -> TableViewDataSource
}

class VirtualCurrencyListDatasource
{
    typealias Item = StoreCurrencyPackage
    typealias ActionHandler = ((VirtualCurrencyItemAction, Item) -> Void)
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
    
    func set(items inputItems: [Item])
    {
        groups = []
        
        var allGroup = [BoxedItem]()
        var groupsDictionary = [String: [BoxedItem]]()
        
        for item in inputItems
        {
            let boxedItem = BoxedItem(value: item)
                
            allGroup.append(boxedItem)
            
            // Groupped items
            for name in getUniqueGroupNames(from: item)
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
        
        setupDataSources()
    }
    
    private func setupDataSources()
    {
        let factory = self.dependencies.dataSourceFactory
        
        self.dataSources = self.groups.enumerated().map
        {
            let params = VirtualCurrencyListGroupDataSourceBuildParams(groupIndex: $0.offset, dataSource: self)
            { [weak self] action, item in
                
                self?.itemActionHandler?(action, item)
            }
            
            let dataSource = factory.createVirtualCurrencyListGroupDataSource(params: params)
            
            return dataSource
        }
    }
    
    private func getUniqueGroupNames(from item: Item) -> Set<GroupName>
    {
        item.content.reduce(into: Set<GroupName>()) { $0.insert($1.name) }
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

extension VirtualCurrencyListDatasource: VirtualCurrencyListDataSourceProtocol
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
