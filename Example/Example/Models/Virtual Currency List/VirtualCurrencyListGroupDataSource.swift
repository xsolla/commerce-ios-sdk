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

class VirtualCurrencyListGroupDataSource: NSObject, TableViewDataSource
{
    typealias CellModel = VirtualCurrencyCell.Model
    typealias Item = VirtualCurrencyListDatasource.Item
    typealias ActionHandler = VirtualCurrencyListDatasource.ActionHandler
 
    var itemActionHandler: ActionHandler?
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let dataSource = dataSource else { fatalError("Undefined datasource") }
        
        return dataSource.numberOfItems(in: groupIndex)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.cell(VirtualCurrencyCell.self, for: indexPath)
        let item = getItem(at: indexPath)
        let model = virtualCurrencyCellModel(for: item)
        
        cell.setup(model: model)
        
        cell.actionHandler =
        { [weak self] action in guard let self = self else { return }
            
            self.itemActionHandler?(action, item)
        }
        
        if isLastCell(at: indexPath) { cell.hideDivider() }
        else                         { cell.showDivider() }
        
        return cell
    }
    
    func getItem(at indexPath: IndexPath) -> Item
    {
        guard let item = dataSource?.getItem(at: indexPath.row, in: groupIndex) else
        {
            fatalError("Undefined datasource")
        }
        
        return item
    }
    
    func virtualCurrencyCellModel(for item: Item) -> VirtualCurrencyCell.Model
    {
        let model = VirtualCurrencyCell.Model(image: getImage(for: item),
                                              title: getTitle(for: item),
                                              price: getPrice(for: item),
                                              discountedPrice: getDiscountedPrice(for: item),
                                              discount: getDiscount(for: item),
                                              description: getDescription(for: item),
                                              action: .buy)
        return model
    }
    
    func getImage(for item: Item) -> Image
    {
        if let url = item.imageUrl { return .url(url) }
        
        return .image(Asset.Images.imagePlaceholder.image)
    }
    
    func getTitle(for item: Item) -> NSAttributedString?
    {
        item.name.attributed(.heading2, color: .xsolla_white)
    }
    
    func getPrice(for item: Item) -> NSAttributedString?
    {
        priceHelper.getPrice(for: item)
    }
    
    func getDiscountedPrice(for item: Item) -> NSAttributedString?
    {
        priceHelper.getDiscountedPrice(for: item)
    }
    
    func getDiscount(for item: Item) -> NSAttributedString?
    {
        priceHelper.getDiscount(for: item)
    }
    
    func getDescription(for item: Item) -> NSAttributedString?
    {
        guard let description = item.description else { return nil }

        return description.attributed(.link, color: .xsolla_lightSlateGrey)
    }
    
    func isLastCell(at indexPath: IndexPath) -> Bool
    {
        guard let dataSource = dataSource else { fatalError("Undefined datasource") }
        
        return indexPath.row == dataSource.numberOfItems(in: groupIndex) - 1
    }
    
    let groupIndex: VirtualCurrencyListDatasource.GroupIndex
    weak var dataSource: VirtualCurrencyListDataSourceProtocol?
    let priceHelper: ItemPriceHelperProtocol
    
    init(groupIndex: VirtualCurrencyListDatasource.GroupIndex,
         dataSource: VirtualCurrencyListDataSourceProtocol,
         priceHelper: ItemPriceHelperProtocol)
    {
        self.groupIndex = groupIndex
        self.dataSource = dataSource
        self.priceHelper = priceHelper
        
        super.init()
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}
