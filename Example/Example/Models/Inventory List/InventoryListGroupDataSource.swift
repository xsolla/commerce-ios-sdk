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
import UIKit

final class InventoryListGroupDataSource: NSObject, TableViewDataSource
{
    typealias CellModel = InventoryCell.Model
    typealias Item = InventoryListDataSource.Item
    typealias ActionHandler = InventoryListDataSource.ActionHandler
 
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
        let cell = tableView.cell(InventoryCell.self, for: indexPath)
        let item = getItem(at: indexPath)
        let model = inventoryItemCellModel(for: item)
        
        cell.setup(model: model)
        
        cell.actionHandler =
        { [weak self] action in guard let self = self else { return }
            
            self.itemActionHandler?(action, item)
        }
        
        if isLastCell(at: indexPath) { cell.hideDivider() }
        else                         { cell.showDivider() }
        
        return cell
    }
    
    let groupIndex: InventoryListDataSource.GroupIndex
    weak var dataSource: InventoryListDataSource?
    let dateFormatter: DateComponentsFormatter =
    {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = [.dropAll]
        formatter.maximumUnitCount = 2
        formatter.collapsesLargestUnit = false

        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        
        return formatter
    }()
    
    init(groupIndex: InventoryListDataSource.GroupIndex,
         dataSource: InventoryListDataSource)
    {
        self.groupIndex = groupIndex
        self.dataSource = dataSource
        
        super.init()
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}

extension InventoryListGroupDataSource
{
    func getItem(at indexPath: IndexPath) -> Item
    {
        guard let item = dataSource?.getItem(at: indexPath.row, in: groupIndex) else
        {
            fatalError("Undefined datasource")
        }

        return item
    }
    
    func inventoryItemCellModel(for item: Item) -> InventoryCell.Model
    {
        let model = InventoryCell.Model(image: getImage(for: item),
                                        imageState: getImageState(for: item),
                                        title: getTitle(for: item),
                                        subtitle: getSubtitle(for: item),
                                        action: getAction(for: item))
        return model
    }
    
    func getAction(for item: Item) -> InventoryItemAction
    {
        if case .expired = item.detailedSubscriptionInfo?.status { return .buyAgain }
        if (item.remainingUses ?? 0) == 0 { return .none }
        if case .consumable = item.virtualItemType { return .consume }
        
        return .none
    }
    
    func getImage(for item: Item) -> Image
    {
        if let url = item.imageUrl { return .url(url) }
        
        return .image(Asset.Images.imagePlaceholder.image)
    }
    
    func getImageState(for item: Item) -> InventoryCell.Model.ImageState
    {
        if case .expired = item.detailedSubscriptionInfo?.status { return .dimmed }
        
        return .normal
    }
    
    func getTitle(for item: Item) -> NSAttributedString?
    {
        var color = UIColor.xsolla_white
        
        if case .expired = item.detailedSubscriptionInfo?.status { color = UIColor.xsolla_lightSlateGrey }
        
        return item.name.attributed(.heading2, color: color)
    }
    
    func getSubtitle(for item: Item) -> NSAttributedString?
    {
        guard item.virtualItemType == .nonRenewingSubscription else
        {
            if let quantity = item.quantity { return String(quantity).attributed(.description, color: .xsolla_white) }
            return nil
        }
        
        guard let subscription = item.detailedSubscriptionInfo else { return nil }
                
        switch subscription.status
        {
            case .active: return getExpirationPeriod(item: item)
            case .expired: return getExpiredSubscriptionAttibutedTitle(item: item)
            case .none: return nil
        }
    }
    
    func getExpiredSubscriptionAttibutedTitle(item: Item) -> NSAttributedString?
    {
        L10n.Inventory.Label.expired.attributed(.description, color: .xsolla_lightSlateGrey)
    }
    
    func getExpirationPeriod(item: Item) -> NSAttributedString?
    {
        guard
            item.type == .virtualGood,
            item.virtualItemType == .some(.nonRenewingSubscription),
            let expirationPeriod = item.detailedSubscriptionInfo?.expiredAt,
            let formattedInterval = dateFormatter.string(from: expirationPeriod.timeIntervalSince(Date()))
        else
            { return nil }
        
        let style = Style.label
        let image = Asset.Images.timerIcon.image

        let attributedString = " \(formattedInterval)"
            .attributed(style, color: .xsolla_white)
            .appendImageCentered(image, to: .left, font: style.font)

        return attributedString
    }
    
    func isLastCell(at indexPath: IndexPath) -> Bool
    {
        guard let dataSource = dataSource else { fatalError("Undefined datasource") }

        return indexPath.row == dataSource.numberOfItems(in: groupIndex) - 1
    }
}
