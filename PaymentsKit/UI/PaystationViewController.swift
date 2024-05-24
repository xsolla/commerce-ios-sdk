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

class PaystationViewController: UIViewController
{
    var completionHandler: ((PaymentStatus) -> Void)?
    var configuration: PaystationWebView.Configuration?
    
    private var paystationWebView: PaystationWebView = PaystationWebView(frame: .zero)
    private var loadingView: PaystationLoadingView = PaystationLoadingView(frame: .zero)
    
    private var paymentStatus: PaymentStatus = .unknown
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupWebView()
        setupLoadingView()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)

        if paymentStatus == .unknown
        {
            completionHandler?(paymentStatus)
        }
    }
    
    private func setupWebView()
    {
        view.addSubview(paystationWebView)
        paystationWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                paystationWebView.topAnchor.constraint(equalTo: view.topAnchor),
                paystationWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                paystationWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                paystationWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        paystationWebView.delegate = self
        paystationWebView.loadingDelegate = self
    }
    
    private func setupLoadingView()
    {
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
    
    func loadPaystation()
    {
        guard let configuration = configuration else { return }
        
        paystationWebView.isHidden = true
        loadingView.isHidden = false
        loadingView.toggleAnimation(true)
        
        paystationWebView.loadPaystation(with: configuration)
    }
    
    func warmupPaystationWebView()
    {
        paystationWebView.warmupWebView()
    }
}

extension PaystationViewController: PaystationWebViewDelegate
{
    public func paystationWebView(_ webView: PaystationWebView,
                                  didFinishPaymentWithInvoice invoiceId: String?,
                                  forUser userId: String?)
    {
        paymentStatus = .success
        completionHandler?(paymentStatus)
    }
}

extension PaystationViewController: PaystationWebViewLoadingDelegate
{
    public func onStartLoad(_ webView: PaystationWebView)
    {
        paystationWebView.isHidden = true
        loadingView.isHidden = false
        loadingView.toggleAnimation(true)
    }
    
    public func onFinishLoad(_ webView: PaystationWebView)
    {
        paystationWebView.isHidden = false
        loadingView.isHidden = true
        loadingView.toggleAnimation(false)
    }
}
