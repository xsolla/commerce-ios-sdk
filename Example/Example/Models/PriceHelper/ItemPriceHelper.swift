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

protocol ItemPriceHelperProtocol
{
    func getPriceCurrencyImage(for item: ItemPriceProvider) -> Image?
    func getPrice(for item: ItemPriceProvider) -> NSAttributedString?
    func getDiscountedPrice(for item: ItemPriceProvider) -> NSAttributedString?
    func getDiscountedPrice(for item: ItemPriceProvider, totalContentPrice: StoreItemPrice?) -> NSAttributedString?
    func getDiscount(for item: ItemPriceProvider) -> NSAttributedString?
}

class ItemPriceHelper: ItemPriceHelperProtocol
{
    func getPriceCurrencyImage(for item: ItemPriceProvider) -> Image?
    {
        guard item.price == nil, let url = item.virtualPrices.first?.imageUrl else { return nil }
        
        return .url(url)
    }
    
    func getPrice(for item: ItemPriceProvider) -> NSAttributedString?
    {
        if let price = item.price?.amount, let currencyCode = item.price?.currency
        {
            return getPrice(price, currencyCode: currencyCode)
        }
        
        if let price = item.virtualPrices.first?.amount
        {
            return getPrice(Double(price))
        }
        
        return nil
    }
    
    func getDiscountedPrice(for item: ItemPriceProvider) -> NSAttributedString?
    {
        if
            let price = item.price?.amount,
            let oldPrice = item.price?.amountWithoutDiscount,
            let currencyCode = item.price?.currency,
            price != oldPrice
        {
            return getDiscountedPrice(oldPrice, currencyCode: currencyCode)
        }

        if
            let price = item.virtualPrices.first?.amount,
            let oldPrice = item.virtualPrices.first?.amountWithoutDiscount,
            price != oldPrice
        {
            return getDiscountedPrice(Double(oldPrice))
        }
        
        return nil
    }
    
    func getDiscountedPrice(for item: ItemPriceProvider, totalContentPrice: StoreItemPrice?) -> NSAttributedString?
    {
        guard let contentPrice = totalContentPrice?.amount else { return getDiscountedPrice(for: item) }
        
        guard
            let price = item.price?.amount,
            price != contentPrice,
            let currencyCode = item.price?.currency
        else
            { return nil }
        
        return getDiscountedPrice(contentPrice, currencyCode: currencyCode)
    }
    
    func getDiscount(for item: ItemPriceProvider) -> NSAttributedString?
    {
        if
            let price = item.price?.amount,
            let oldPrice = item.price?.amountWithoutDiscount,
            price != oldPrice
        {
            return getDiscount(price: price, oldPrice: oldPrice)
        }
        
        if
            let price = item.virtualPrices.first?.amount,
            let oldPrice = item.virtualPrices.first?.amountWithoutDiscount,
            price != oldPrice
        {
            return getDiscount(price: Double(price), oldPrice: Double(oldPrice))
        }
        
        return nil
    }
    
    // MARK: - Initialization
    
    private var formatter: CurrencyFormatterProtocol
    
    init(formatter: CurrencyFormatterProtocol)
    {
        self.formatter = formatter
    }
    
    // MARK: - Private
    
    private func getPrice(_ price: Double, currencyCode: String? = nil) -> NSAttributedString?
    {
        if let code = currencyCode
        {
            return attributedPrice(formatter.string(for: price, withCurrencyCode: code))
        }
        else
        {
            return attributedPrice(String(format: "%.0f", price))
        }
    }
    
    private func getDiscountedPrice(_ price: Double, currencyCode: String? = nil) -> NSAttributedString?
    {
        if let code = currencyCode
        {
            return attributedDiscountedPrice(formatter.string(for: price, withCurrencyCode: code))
        }
        else
        {
            return attributedDiscountedPrice(String(format: "%.0f", price))
        }
    }
    
    private func getDiscount(price: Double, oldPrice: Double) -> NSAttributedString?
    {
        let discount = Double(100 - (price * 100 / oldPrice))
        let discountText = "-\(String(format: "%.0f", discount))%"
        
        return attributedDiscount(discountText)
    }

    // MARK: - Styles
    
    private func attributedPrice(_ string: String) -> NSAttributedString
    {
        string.attributed(.description, color: .xsolla_white)
    }
    
    private func attributedDiscountedPrice(_ string: String) -> NSAttributedString
    {
        string.attributed(.discount, color: .xsolla_lightSlateGrey).striked
    }
    
    private func attributedDiscount(_ string: String) -> NSAttributedString
    {
        string.attributed(.caption, color: .xsolla_onSurfaceHigh)
    }
}
