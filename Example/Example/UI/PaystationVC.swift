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
import WebKit
import XsollaSDKPaymentsKit

class PaystationVC: BaseViewController
{
    var onSuccessPurchase: ((PaystationVC) -> Void)?
    
    var configuration: PaystationWebView.Configuration?
    
    private var paystationWebView: PaystationWebView = PaystationWebView(frame: .zero)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupWebView()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadPaystation()
    }
    
    private func setupWebView()
    {
        view.addSubview(paystationWebView)
        paystationWebView.pinToSuperview()
    }
    
    func loadPaystation()
    {
        guard let configuration = configuration else { return }
        
        paystationWebView.delegate = self
        
        paystationWebView.loadPaystation(with: configuration)
    }
}

extension PaystationVC: PaystationWebViewDelegate
{
    func paystationWebView(_ webView: PaystationWebView,
                           didFinishPaymentWithInvoice invoiceId: String?,
                           forUser userId: String?)
    {
        logger.info { "Paystation View did finish payment" }
        
        onSuccessPurchase?(self)
    }
}
