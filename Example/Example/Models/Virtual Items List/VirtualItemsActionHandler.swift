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
import XsollaSDKStoreKit

class VirtualItemsActionHandler
{
    var bundlePreviewRequest: ((StoreBundle) -> Void)?
    var reloadDataRequest: (() -> Void)?
    var orderPaymentHandler: ((StoreOrderPaymentInfo) -> Void)?

    private var dataSource: VirtualItemsListDatasource
    private var viewController: VirtualItemsVCProtocol
    private var virtualItemsList: VirtualItemsList
    private var store: StoreProtocol

    init(dataSource: VirtualItemsListDatasource,
         viewController: VirtualItemsVCProtocol,
         virtualItemsList: VirtualItemsList,
         store: StoreProtocol)
    {
        self.dataSource = dataSource
        self.viewController = viewController
        self.virtualItemsList = virtualItemsList
        self.store = store

        setupDataSource()
    }

    private func setupDataSource()
    {
        dataSource.itemActionHandler =
        { [weak self] action, item in

            switch action
            {
                case .buyWithRealCurrency: self?.buy(item: item)
                case .buyWithVirtualCurrency(let sku): self?.buy(item: item, withVirtialCurrency: sku)
                case .previewBundle: self?.previewBundle(for: item)

                case .none: break
            }
        }
    }

    /// Buy a virtual item or bundle with a real currency.
    private func buy(item: VirtualItemsListDatasource.Item)
    {
        logger.info { "Buy item: \(item.name) with REAL currency" }

        store.createOrder(itemSKU: item.sku,
                          currency: nil,
                          locale: "",
                          isSandbox: true)
        { [weak self] result in
            switch result
            {
                case .success(let createdOrder): self?.orderPaymentHandler?(createdOrder)

                case .failure(let error): logger.error { error }
            }
        }
    }

    /// Buy a virtual item or bundle with a virtual currency.
    private func buy(item: VirtualItemsListDatasource.Item, withVirtialCurrency currencySku: String)
    {
        logger.info { "Buy item: \(item.name) with VIRTUAL currency" }

        store.purchase(itemSku: item.sku, withCurrencySku: currencySku)
        { [weak self] result in

            switch result
            {
                case .success(let orderId): do
                {
                    logger.info { "Bought item: \(item.name), order id: \(orderId)" }
                    self?.reloadDataRequest?()
                }

                case .failure(let error): do
                {
                    switch error
                    {
                        case StoreKitError.notEnoughVirtualCurrency: logger.error { "Not enough currency" }
                        default: logger.error { error }
                    }
                }
            }
        }
    }

    private func previewBundle(for item: VirtualItemsListDatasource.Item)
    {
        guard let bundle = dataSource.bundles[item.sku] else { return }

        logger.info { "Preview action for item: \(item.name)" }

        bundlePreviewRequest?(bundle)
    }
}
