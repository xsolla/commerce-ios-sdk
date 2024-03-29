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
import XsollaSDKUtilities

class PaymentsAPI
{
    let requestPerformer: RequestPerformer
    let responseProcessor: ResponseProcessor
    let paystationVersion: PaystationVersion
    
    init(requestPerformer: RequestPerformer, responseProcessor: ResponseProcessor, paystationVersion: PaystationVersion)
    {
        logger.debug(.initialization, domain: .paymentsKit) { String(describing: Self.self) }
        
        self.requestPerformer = requestPerformer
        self.responseProcessor = responseProcessor
        self.paystationVersion = paystationVersion
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .paymentsKit) { deinitingType }
    }
}

extension PaymentsAPI: PaymentsAPIProtocol
{
    func createPaymentUrl(paymentToken: String, isSandbox: Bool) -> URL?
    {
        let baseUrlString = getPaystationBasePath(isSandbox: isSandbox) + getPaystationVersionPath()
        
        guard var urlComponents = URLComponents(string: baseUrlString) else
        {
            return nil
        }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(getTokenQuery(paymentToken: paymentToken))
        queryItems.append(contentsOf: getAnalyticsQueries())
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else
        {
            return nil
        }
        
        logger.debug(.debug, domain: .paymentsKit) { url }
        return url
    }
    
    func getWarmupUrl() -> URL? 
    {
        return URL(string: "https://secure.xsolla.com/" + getPaystationVersionPath() + "/" + getLocalePath() + "/cache-warmup")
    }
    
    private func getLocalePath() -> String
    {
        if let systemLanguageCode = Locale.preferredLanguages.first,
           let primaryLanguageCode = systemLanguageCode.split(separator: "-").first
        {
            return String(primaryLanguageCode)
        }
        
        return "en"
    }
    
    private func getPaystationBasePath(isSandbox: Bool) -> String
    {
        return isSandbox
            ? "https://sandbox-secure.xsolla.com/"
            : "https://secure.xsolla.com/"
    }
    
    private func getPaystationVersionPath() -> String
    {
        switch paystationVersion 
        {
            case .v3: return "paystation3"
            case .v4: return "paystation4"
        }
    }
    
    private func getTokenQuery(paymentToken: String) -> URLQueryItem
    {
        switch paystationVersion 
        {
            case .v3: return URLQueryItem(name: "access_token", value: paymentToken)
            case .v4: return URLQueryItem(name: "token", value: paymentToken)
        }
    }
    
    private func getAnalyticsQueries() -> [URLQueryItem]
    {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "engine", value: "ios"),
            URLQueryItem(name: "engine_v", value: UIDevice.current.systemVersion),
            URLQueryItem(name: "sdk", value: PaymentsAnalyticsUtils.sdk),
            URLQueryItem(name: "sdk_v", value: PaymentsAnalyticsUtils.sdkVersion)
        ]
                
        if !PaymentsAnalyticsUtils.gameEngine.isEmpty
        {
            queryItems.append(URLQueryItem(name: "game_engine", value: PaymentsAnalyticsUtils.gameEngine))
        }
        
        if !PaymentsAnalyticsUtils.gameEngineVersion.isEmpty
        {
            queryItems.append(URLQueryItem(name: "game_engine_v", value: PaymentsAnalyticsUtils.gameEngineVersion))
        }
        
        return queryItems
    }
}

extension PaymentsAPI
{
    var configuration: PaymentsAPIConfiguration
    {
        PaymentsAPIConfiguration(requestPerformer: requestPerformer,
                                 responseProcessor: responseProcessor,
                                 apiBasePath: "http://0.0.0.0:3000/")
    }
}
