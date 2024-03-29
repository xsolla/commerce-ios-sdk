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

typealias CurrencyIsoCode = String

protocol CurrencyProviderProtocol
{
    var currenciesDictionary: [String: Currency] { get }
    var currenciesArray: [Currency] { get }
    func currency(isoCode: CurrencyIsoCode) -> Currency?
}

class CurrencyProvider: CurrencyProviderProtocol
{
    // MARK: - Public
    
    var currenciesDictionary: [CurrencyIsoCode: Currency] { supportedCurrencies }
    var currenciesArray: [Currency] { [Currency](supportedCurrencies.values) }
    func currency(isoCode: CurrencyIsoCode) -> Currency?
    {
        currencies[isoCode]
    }
    
    func setup(with currencies: [CurrencyIsoCode: Currency])
    {
        self.currencies = currencies
    }

    // MARK: - Private
    
    private var currencies: [CurrencyIsoCode: Currency]

    init()
    {
        let jsonDecoder = JSONDecoder()
        
        guard
            let jsonFile = Bundle.main.path(forResource: "currency-format", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonFile)),
            let decodedCurrencies = try? jsonDecoder.decode([CurrencyIsoCode: DecodedCurrency].self, from: jsonData)
        else
        {
            self.currencies = [:]
            return
        }
        
        var currencies: [CurrencyIsoCode: Currency] = [:]
        
        for (isoCode, decodedCurrency) in decodedCurrencies
        {
            let symbol = Currency.Symbol(grapheme: decodedCurrency.symbol.grapheme,
                                         template: decodedCurrency.symbol.template,
                                         rtl: decodedCurrency.symbol.rtl)
            
            var uniqueSymbol: Currency.Symbol?
            
            if let decodedUniqueSymbol = decodedCurrency.uniqueSymbol
            {
                uniqueSymbol = Currency.Symbol(grapheme: decodedUniqueSymbol.grapheme,
                                               template: decodedUniqueSymbol.template,
                                               rtl: decodedUniqueSymbol.rtl)
            }
                
            let currency = Currency(name: decodedCurrency.name,
                                    fractionSize: decodedCurrency.fractionSize,
                                    symbol: symbol,
                                    uniqueSymbol: uniqueSymbol,
                                    isoCode: isoCode)
            
            currencies[isoCode] = currency
        }
        
        self.currencies = currencies
    }
    
    lazy var supportedCurrencies: [CurrencyIsoCode: Currency] =
    {
        var supportedCurrenciesSet = Set(supportedIsoCodes)
        var filteredCurrencies = currencies
        
        for (isoCode, value) in filteredCurrencies
        {
            if supportedCurrenciesSet.contains(isoCode)
            {
                supportedCurrenciesSet.remove(isoCode)
            }
            else
            {
                filteredCurrencies[isoCode] = nil
            }
        }
        
        return filteredCurrencies
    }()
    
    // swiftlint:disable line_length
    var supportedIsoCodes: [CurrencyIsoCode]
    {
        let rawList = "RUB,USD,EUR,UAH,GBP,CZK,MDL,ARS,KZT,AUD,CAD,CHF,CLP,DKK,HRK,HUF,NOK,NZD,PLN,SEK,SKK,BGN,LVL,MXN,HKD,IDR,MYR,BRL,SGD,RON,AMD,TRY,MDL,TJS,MCI,ZXT,EEK,INR,LTL,ZAR,THB,AED,ILS,SAR,CNY,KGS,PHP,AZN,BOB,COP,EGP,GTQ,HNL,KRW,MAD,MKD,PEN,RSD,SYP,TWD,UGX,VND,UZS,KWD,YER,QAR,JOD,BHD,OMR,TND,SDG,IQD,BAM,VEF,CC,ALL,JPY,GEL,ARS,VEF,UYU,DOP,DZD,KES,MNT,PKR,NGN,BWP,CRC,XCD,GEL,LBP,NIO,PAB,XC,NPR,FJD,LKR,LAK,JMD,IRR,PYG,TTD,MUR,ZWD,SVC,SRD,GYD,MZN,ISK,BSD,AFN,SOS,BBD,XOF,KMF,BND,USD,UAH,NAD,FKP,GHS,BZD,GIP,TMT,LRD,BYN,MMK,BTC,ETH,LTC,MGO,GMC,VES,GNG"
        
        return rawList
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}
