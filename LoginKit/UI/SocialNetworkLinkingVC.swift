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

import UIKit
import WebKit
import XsollaSDKUtilities

/**
 View Controller for linking social network account to Xsolla account.
 Use the `startLinking` function to initiate linking proccess.
 */
public class SocialNetworkLinkingVC: UIViewController
{
    private var completion: ((Result<Void, Error>, SocialNetworkLinkingVC) -> Void)?

    private var webView: WKWebView = WKWebView()
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    private var loginURLString: String?

    public override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        setupActivityIndicator()
    }

    private func setupActivityIndicator()
    {
        activityIndicator.color = .gray

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func setupWebView()
    {
        webView.customUserAgent = WKWebView.defaultUserAgent

        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func showLoading()
    {
        webView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoading()
    {
        webView.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    // MARK: - Public

    /**
     Performs linking of social network account to Xsolla account.
     - Parameters:
        - providerName: Name of the social network connected to Login in Publisher Account.
     Can be: *amazon*, *apple*, *baidu*, *battlenet*, *discord*, *facebook*, *github*, *google*, *kakao*, *linkedin*,
     *mailru*, *microsoft*, *msn*, *naver*, *ok*, *paypal*, *psn*, *reddit*, *steam*, *twitch*, *twitter*, *vimeo*, *vk*,
     *wechat*, *weibo*, *yahoo*, *yandex*, *youtube*, *xbox*.
        - accessToken:  By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - loginURL: URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation. Must be identical to the **Callback URL** specified in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **General settings** > **URL**. **Required** if there are several Callback URLs.
        - completion: Result with instance of the current View Controller.
     */
    public func startLinking(toProvider providerName: String,
                             withAccessToken accessToken: String,
                             loginURL: String,
                             completion: ((Result<Void, Error>, SocialNetworkLinkingVC) -> Void)?)
    {
        self.loginURLString = loginURL
        self.completion = completion

        showLoading()

        LoginKit.shared.getURLToLinkSocialNetworkToAccount(accessToken: accessToken,
                                                           providerName: providerName,
                                                           loginURL: loginURL)
        { [weak self] result in guard let self = self else { return }

            self.hideLoading()

            switch result
            {
                case .success(let linkingURLString): do
                {
                    guard let url = URL(string: linkingURLString)
                    else
                    {
                        completion?(.failure(SocialNetworkLinkingError.InvalidURL), self)
                        return
                    }

                    self.webView.load(URLRequest(url: url))
                }

                case .failure(let error): do
                {
                    completion?(.failure(error), self)
                }
            }
        }
    }
}

extension SocialNetworkLinkingVC: WKNavigationDelegate
{
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let url = navigationAction.request.url,
              let callbackURLString = loginURLString,
              url.absoluteString.starts(with: callbackURLString)
        else
        {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        completion?(.success(()), self)
    }
}

extension SocialNetworkLinkingVC
{
    enum SocialNetworkLinkingError: LocalizedError
    {
        case InvalidURL

        var errorDescription: String?
        {
            switch self
            {
                case .InvalidURL: return "Invalid URL received from the server"
            }
        }
    }
}
