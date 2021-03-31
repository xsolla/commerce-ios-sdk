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
import XsollaSDKInventoryKit

protocol VirtualCurrencyBalanceProviderDelegate: AnyObject
{
    func didRecieveCurrencyBalance(currency1Balance: VirtualCurrencyBalance, currency2Balance: VirtualCurrencyBalance)
}

class VirtualCurrencyBalanceProvider
{
    weak var delegate: VirtualCurrencyBalanceProviderDelegate?
    
    let xsollaSDK: XsollaSDKProtocol
    let projectId: Int
    
    init(xsollaSDK: XsollaSDKProtocol, projectId: Int)
    {
        self.xsollaSDK = xsollaSDK
        self.projectId = projectId
    }
    
    func requestData()
    {
        xsollaSDK.getUserVirtualCurrencyBalance(projectId: projectId, platform: nil)
        { [weak self] result in
            switch result
            {
                case .success(let balances): do
                {
                    guard balances.count > 1 else { return }
                    
                    let currency1Balance = VirtualCurrencyBalance(balance: String(balances[0].amount),
                                                                  iconUrl: URL(string: balances[0].imageUrl ?? ""))
                    
                    let currency2Balance = VirtualCurrencyBalance(balance: String(balances[1].amount),
                                                                  iconUrl: URL(string: balances[1].imageUrl ?? ""))
                    
                    self?.delegate?.didRecieveCurrencyBalance(currency1Balance: currency1Balance,
                                                              currency2Balance: currency2Balance)
                }
                
                case .failure(let error): logger.error { error }
            }
        }
    }
}
