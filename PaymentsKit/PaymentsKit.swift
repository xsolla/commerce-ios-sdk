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
import XsollaSDKUtilities
import UIKit

public final class PaymentsKit
{
    public static let shared = PaymentsKit()

    private let paystationViewController: PaystationViewController = PaystationViewController()
    private let api: PaymentsAPIProtocol

    public convenience init(paystationVersion: PaystationVersion = .v4)
    {
        let requestPerformer = XSDKNetwork(sessionConfiguration: XSDKNetwork.defaultSessionConfiguration)
        let responseProcessor = PaymentsAPIResponseProcessor()
        let api = PaymentsAPI(requestPerformer: requestPerformer,
                              responseProcessor: responseProcessor,
                              paystationVersion: paystationVersion)

        self.init(api: api)
    }

    init(api: PaymentsAPIProtocol, paystationVersion: PaystationVersion = .v4)
    {
        self.api = api
    }
}

extension PaymentsKit
{

    /**
    Creates a link for redirecting a user to a payment system.

     - Parameters:
       - paymentToken: Payment token.
       - isSandbox: Creates an order in the sandbox mode. The option is available for the company users only. Это я скопировал из другого места, но выглядит глупо в данном контексте.
     - Returns: URL for opening the payment UI.
     */
    public func createPaymentUrl(paymentToken: String, isSandbox: Bool) -> URL?
    {
        api.createPaymentUrl(paymentToken: paymentToken, isSandbox: isSandbox)
    }

    /// Returns a URL that can be used to "warm up" Pay Station web page for faster display later on
    public func getPaymentWarmupUrl() -> URL?
    {
        return api.getWarmupUrl()
    }

    /// Warms up the internal Pay Station WebView
    public func warmupPaymentView()
    {
        paystationViewController.warmupPaystationWebView()
    }

    /// Displays internal Pay Station WebView
    public func presentPaymentView(presenter: UIViewController,
                                   paymentToken: String,
                                   isSandbox: Bool,
                                   redirectUrl: String,
                                   completionHandler: ((PaymentStatus) -> Void)?)
    {
        let controller = paystationViewController
        controller.configuration = .init(paymentToken: paymentToken, redirectURL: redirectUrl, isSandbox: isSandbox)

        controller.completionHandler =
        { status in
            controller.dismiss(animated: true, completion: nil)
            completionHandler?(status)
        }

        controller.loadPaystation()
        presenter.present(controller, animated: true, completion: nil)
    }
}
