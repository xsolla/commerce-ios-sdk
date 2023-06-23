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
    var bundlePreviewRequest: ((StoreBundle, BundlePreviewActionHandler?) -> Void)?
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

        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
    
    private func setupDataSource()
    {
        dataSource.itemActionHandler =
        { [weak self] action, item in

            switch action
            {
                case .buyFree: self?.buyFree(item: item)
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
                          quantity: 1,
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
    
    /// Buy a free virtual item.
    private func buyFree(item: VirtualItemsListDatasource.Item)
    {
        logger.info { "Buy free item: \(item.name)" }

        store.purchaseFreeItem(itemSKU: item.sku)
        { [weak self] result in

            switch result
            {
                case .success(let orderId): do
                {
                    logger.info { "Bought free item: \(item.name), order id: \(orderId)" }
                    self?.reloadDataRequest?()
                }

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
        { [weak self] action in

            switch action
            {
                case .buy: self?.handleBundleBuyRequest(for: item)
            }
        }
    }

    func handleBundleBuyRequest(for item: VirtualItemsListDatasource.Item)
    {
        if let virtualCurrency = item.virtualPrices.first
        {
            buy(item: item, withVirtialCurrency: virtualCurrency.sku)
        }
        else
        {
            buy(item: item)
        }
    }
}
