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
import XsollaSDKUtilities

public protocol PaystationWebViewDelegate: AnyObject
{
    func paystationWebView(_ webView: PaystationWebView,
                           didFinishPaymentWithInvoice invoiceId: String?,
                           forUser userId: String?)
}

/**
 Pay Station is a complete payment UI that allows your users to purchase games and items on your website.
 To easily implement the payment UI, just add PaystationWebView to your application.

 Call `func loadPaystation(with configuration: Configuration)` to initiate payment.
 */
public class PaystationWebView: UIView
{
    public weak var delegate: PaystationWebViewDelegate?
    
    public var customUserAgent: String = WKWebView.defaultUserAgent
    {
        didSet { webView.customUserAgent = customUserAgent }
    }
    
    internal var loadingDelegate: PaystationWebViewLoadingDelegate?
    private var configuration: Configuration?

    private var webView: WKWebView = WKWebView()
    
    // MARK: - Initialization

    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit()
    {
        setupWebView()
    }

    private func setupWebView()
    {
#if DEBUG
        if #available(iOS 16.4, *)
        {
            webView.isInspectable = true
        }
#endif
        webView.customUserAgent = customUserAgent
        webView.navigationDelegate = self

        self.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    // MARK: - Public

    public func loadPaystation(with configuration: Configuration)
    {
        self.configuration = configuration
        let url = configuration.buildURL()
        loadUrl(url: url)
    }
    
    public func warmupWebView()
    {
        let url = PaymentsKit.shared.getPaymentWarmupUrl()
        loadUrl(url: url!)
    }
    
    func loadUrl(url: URL)
    {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension PaystationWebView: WKNavigationDelegate
{
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let url = navigationAction.request.url,
              let redirectURL = configuration?.redirectURL,
              url.absoluteString.starts(with: redirectURL)
        else
        {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)

        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let invoiceId = urlComponents?.queryItems?.first(where: { $0.name == "invoice_id" })?.value
        let userId = urlComponents?.queryItems?.first(where: { $0.name == "user_id" })?.value

        delegate?.paystationWebView(self, didFinishPaymentWithInvoice: invoiceId, forUser: userId)
    }
    
    public func webView(_ webView: WKWebView, 
                        didStartProvisionalNavigation navigation: WKNavigation!)
    {
        loadingDelegate?.onStartLoad(self)
    }
    
    public func webView(_ webView: WKWebView,
                        didFinish navigation: WKNavigation!)
    {
        loadingDelegate?.onFinishLoad(self)
    }

}

// MARK: - Configuration

extension PaystationWebView
{
    /// Struct to configure PaystationWebView.
    public struct Configuration
    {
        /// Payment token received by `StoreKit.createOrder()` or by [Store API](https://developers.xsolla.com/store-api/cart-payment/payment/create-order-with-item/).
        let paymentToken: String

        /// Redirect URL that you can specify in your Publisher Account.
        let redirectURL: String

        /// `true` for sandbox environment.
        let isSandbox: Bool

        /**
         - Parameters:
            - accessToken: Payment token received by `StoreKit.createOrder()` or by [Store API](https://developers.xsolla.com/store-api/cart-payment/payment/create-order-with-item/).
            - redirectURL: Redirect URL that you can specify in your Publisher Account.
            - isSandbox: `true` for sandbox environment.
         */
        public init(paymentToken: String, redirectURL: String, isSandbox: Bool = false)
        {
            self.paymentToken = paymentToken
            self.redirectURL = redirectURL
            self.isSandbox = isSandbox
        }

        public func buildURL() -> URL
        {
            return PaymentsKit.shared.createPaymentUrl(paymentToken: paymentToken, isSandbox: isSandbox)!
        }
    }
}
