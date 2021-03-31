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

class BundlePreviewDataSource: NSObject, TableViewDataSource
{
    typealias Item = StoreBundle.ContentItem
    
    private let bundle: StoreBundle
    private var items: [Item] { bundle.content }
    private let priceHelper: ItemPriceHelperProtocol
    
    var bundleImage: Image
    {
        if let imageUrl = bundle.imageUrl { return .url(imageUrl) }
        else                              { return .image(Asset.Images.imagePlaceholder.image) }
    }
    
    var bundlePriceCurrencyImage: Image?
    {
        priceHelper.getPriceCurrencyImage(for: bundle)
    }
    
    var bundleName: NSAttributedString
    {
        bundle.name.attributed(.heading2, color: .xsolla_white)
    }
    
    var bundleDescription: NSAttributedString?
    {
        var description = bundle.description != nil ? "\(bundle.description!)\n":  ""
        
        description += "This bundle includes \(items.count) items:"
        
        return description.attributed(.description, color: .xsolla_lightSlateGrey)
    }
    
    var bundlePrice: NSAttributedString?
    {
        priceHelper.getPrice(for: bundle)
    }
    
    var bundleDiscountedPrice: NSAttributedString?
    {
        if let contentPrice = bundle.totalContentPrice
        {
            return priceHelper.getDiscountedPrice(for: bundle, totalContentPrice: contentPrice)
        }
        
        return priceHelper.getDiscountedPrice(for: bundle)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.cell(BundleContentListCell.self, for: indexPath)
        
        cell.setup(model: cellModel(at: indexPath))
        
        if isLastCell(at: indexPath) { cell.hideDivider() }
        else                         { cell.showDivider() }
        
        return cell
    }
    
    init(bundle: StoreBundle, priceHelper: ItemPriceHelperProtocol)
    {
        self.bundle = bundle
        self.priceHelper = priceHelper
    }
    
    private func cellModel(at indexPath: IndexPath) -> BundleContentListCell.Model
    {
        let item = items[indexPath.row]
        
        let model = BundleContentListCell.Model(image: getImage(for: item),
                                                title: getTitle(for: item),
                                                amount: getAmount(for: item),
                                                description: getDescription(for: item),
                                                expirationPeriod: getExpirationPeriod(for: item))
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
    
    func getAmount(for item: Item) -> NSAttributedString?
    {
        String(item.quantity).attributed(.description, color: .xsolla_white)
    }
    
    func getDescription(for item: Item) -> NSAttributedString?
    {
        guard let description = item.description else { return nil }
        
        return description.attributedMutable(.link, color: .xsolla_lightSlateGrey)
    }
    
    func getExpirationPeriod(for item: Item) -> NSAttributedString?
    {
        guard
            case .virtualGood = ItemType(rawValue: item.type),
            case .nonRenewingSubscription = VirtualItemType(rawValue: item.virtualItemType),
            let expirationPeriod = item.inventoryOptions.expirationPeriod,
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
        return indexPath.row == items.count - 1
    }
}
