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

final class CurrencyFormatter
{
    private let leftToRightCharacter = Character("\u{200E}")
    private let numberFormatter: NumberFormatter = NumberFormatter()
    private var currencies: [CurrencyIsoCode: Currency]
        
    init(currencies: [CurrencyIsoCode: Currency])
    {
        self.currencies = currencies
    }
    
    func string(for value: NSNumber, withCurrencyCode currencyCode: String? = nil) -> String
    {
        let currency = currencies[currencyCode ?? ""]
        let numberFormatter = getNumberFormatter(forCurrency: currency)
        
        guard var formattedString = numberFormatter.string(from: value as NSNumber) else { return "" }
        
        if let currency = currency
        {
            let currencySymbol = currency.uniqueSymbol ?? currency.symbol
            formattedString = currencySymbol.template
                .replacingOccurrences(of: "1", with: formattedString)
                .replacingOccurrences(of: "$", with: currencySymbol.grapheme)

            if currencySymbol.rtl { formattedString = "\(leftToRightCharacter)\(formattedString)" }
        }

        return formattedString
    }
    
    func string(for value: NSNumber, usingCurrencyCode currencyCode: String? = nil) -> String
    {
        let currency = currencies[currencyCode ?? ""]
        let numberFormatter = getNumberFormatter(forCurrency: currency)
        
        guard var formattedString = numberFormatter.string(from: value as NSNumber) else { return "" }
        
        if let currencyCode = currencyCode, currency != nil
        {
            formattedString = "\(formattedString) \(currencyCode)"
        }

        return formattedString
    }
    
    private func getNumberFormatter(forCurrency currency: Currency? = nil) -> NumberFormatter
    {
        numberFormatter.groupingSeparator = ","
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.zeroSymbol = "0"
        numberFormatter.maximumFractionDigits = currency?.fractionSize ?? 2
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.roundingMode = .halfUp
        
        return numberFormatter
    }
}

extension CurrencyFormatter: CurrencyFormatterProtocol
{
    func string<T: Numeric>(for value: T, withCurrencyCode currencyCode: String? = nil) -> String
    {
        guard let number = value as? NSNumber else { return "" }
        
        return string(for: number, withCurrencyCode: currencyCode)
    }
    
    func string<T: Numeric>(for value: T,
                            withCurrencyCode currencyCode: String?,
                            preferCurrencyCodeOverGrapheme useCode: Bool) -> String
    {
        guard let number = value as? NSNumber else { return "" }
        
        return useCode ? string(for: number, usingCurrencyCode: currencyCode)
                       : string(for: number, withCurrencyCode: currencyCode)
    }

}
