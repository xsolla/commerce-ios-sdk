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
import WebKit

protocol WebBrowserVCProtocol: BaseViewController
{
    var initialURL: URL? { get set }
    var navigationDelegate: WKNavigationDelegate? { get set }

    func open(url: URL)
}

class WebBrowserVC: BaseViewController, WebBrowserVCProtocol
{
    // MARK: - Public

    weak var navigationDelegate: WKNavigationDelegate? { didSet { webView.navigationDelegate = navigationDelegate } }

    var initialURL: URL?

    func open(url: URL)
    {
        guard isViewLoaded else { return }

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

    // MARK: - Private

    private let webView = WKWebView()

    // MARK: - Lifecycle

    init(initialURL: URL?)
    {
        super.init(nibName: nil, bundle: nil)
        self.initialURL = initialURL
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupWebView()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        if let url = initialURL { open(url: url) }
    }

    // MARK: - Setups

    private func setupWebView()
    {
        view.addSubview(webView)
        webView.pinToSuperview()
        webView.navigationDelegate = navigationDelegate

        // swiftlint:disable:next line_length
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1"
    }
}

/// Tracks web browser redirects and returns a URL if it is the same as the passed
class WebRedirectHandler: NSObject, WKNavigationDelegate
{
    var onRedirect: ((URL) -> WKNavigationActionPolicy)?

    override init()
    {
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let url = navigationAction.request.url else { decisionHandler(.allow); return }
        decisionHandler(onRedirect?(url) ?? .allow)
    }
}
