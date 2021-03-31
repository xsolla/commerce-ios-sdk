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

class VirtualItemsListGroupDataSource: NSObject, TableViewDataSource
{
    typealias CellModel = VirtualItemCell.Model
    typealias Item = VirtualItemsListDatasource.Item
    typealias ActionHandler = VirtualItemsListDatasource.ActionHandler
 
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
        let cell = tableView.cell(VirtualItemCell.self, for: indexPath)
        let item = getItem(at: indexPath)
        let model = virtualItemCellModel(for: item)
        
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
    
    func virtualItemCellModel(for item: Item) -> VirtualItemCell.Model
    {
        let model = VirtualItemCell.Model(image: getImage(for: item),
                                              title: getTitle(for: item),
                                              price: getPrice(for: item),
                                              discountedPrice: getDiscountedPrice(for: item),
                                              discount: getDiscount(for: item),
                                              description: getDescription(for: item),
                                              expirationPeriod: getExpirationPeriod(for: item),
                                              action: getAction(for: item),
                                              extraAction: getExtraAction(for: item),
                                              currencyImage: getPriceCurrencyImage(for: item))
        return model
    }
    
    func isPurchasedNonConsumable(item: Item) -> Bool
    {
        item.existsInInventory && item.virtualItemType == .some(.nonConsumable)
    }
    
    func getAction(for item: Item) -> VirtualItemsListItemAction
    {
        if isPurchasedNonConsumable(item: item) { return .none }
        
        if let virtualCurrency = item.virtualPrices.first
        {
            return .buyWithVirtualCurrency(currencySku: virtualCurrency.sku)
        }
        else
        {
            return .buyWithRealCurrency
        }
    }
    
    func getExtraAction(for item: Item) -> VirtualItemsListItemAction
    {
        item.type == .bundle ? .previewBundle : .none
    }
    
    func getImage(for item: Item) -> Image
    {
        if let url = item.imageUrl { return .url(url) }
        
        return .image(Asset.Images.imagePlaceholder.image)
    }
    
    func getPriceCurrencyImage(for item: Item) -> Image?
    {
        if isPurchasedNonConsumable(item: item) { return nil }

        return priceHelper.getPriceCurrencyImage(for: item)
    }
    
    func getTitle(for item: Item) -> NSAttributedString?
    {
        item.name.attributed(.heading2, color: .xsolla_white)
    }
    
    func getPrice(for item: Item) -> NSAttributedString?
    {
        if isPurchasedNonConsumable(item: item)
        {
            return L10n.VirtualItems.purchased.attributed(.description, color: .xsolla_lightSlateGrey)
        }

        return priceHelper.getPrice(for: item)
    }
    
    func getDiscountedPrice(for item: Item) -> NSAttributedString?
    {
        if isPurchasedNonConsumable(item: item) { return nil }
        
        return priceHelper.getDiscountedPrice(for: item, totalContentPrice: item.totalContentPrice)
    }
    
    func getDiscount(for item: Item) -> NSAttributedString?
    {
        priceHelper.getDiscount(for: item)
    }
    
    func getDescription(for item: Item) -> NSAttributedString?
    {
        guard let description = item.description else { return nil }
        
        return description.attributedMutable(.link, color: .xsolla_lightSlateGrey)
    }
    
    func getExpirationPeriod(for item: Item) -> NSAttributedString?
    {
        guard
            item.type == .virtualGood,
            item.virtualItemType == .some(.nonRenewingSubscription),
            let expirationPeriod = item.inventoryOptions?.expirationPeriod,
            let localizedInterval = CalendarComponent(rawValue: expirationPeriod.type)?.localizedInterval(for: expirationPeriod.value) // swiftlint:disable:this line_length
        else
            { return nil }
        
        let style = Style.label
        let image = Asset.Images.timerIcon.image

        let attributedString = " \(localizedInterval)"
            .attributed(style, color: .xsolla_white)
            .appendImageCentered(image, to: .left, font: style.font)

        return attributedString
    }
    
    func isLastCell(at indexPath: IndexPath) -> Bool
    {
        guard let dataSource = dataSource else { fatalError("Undefined datasource") }
        
        return indexPath.row == dataSource.numberOfItems(in: groupIndex) - 1
    }
    
    let groupIndex: VirtualItemsListDatasource.GroupIndex
    weak var dataSource: VirtualItemsListDataSourceProtocol?
    let priceHelper: ItemPriceHelperProtocol
    
    init(groupIndex: VirtualItemsListDatasource.GroupIndex,
         dataSource: VirtualItemsListDataSourceProtocol,
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
