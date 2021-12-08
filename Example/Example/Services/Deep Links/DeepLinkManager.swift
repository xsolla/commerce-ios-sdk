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

protocol DeepLinkManagerProtocol
{
    var deepLink: DeepLink? { get }
    func invalidateDeeplink()
    func addObserver(_ observer: DeepLinkManagerObserver)
}

protocol DeepLinkManagerObserver: AnyObject
{
    func deepLinkManager(_ manager: DeepLinkManagerProtocol, didRegisterDeepLink deepLink: DeepLink)
}

class DeepLinkManager: DeepLinkManagerProtocol
{
    private(set) static var shared: DeepLinkManager = DeepLinkManager()

    private(set) var deepLink: DeepLink?

    private var observers: [WeakObserver] = []

    private func register(deepLink: DeepLink?)
    {
        self.deepLink = deepLink

        guard let deepLink = deepLink else { return }

        observers.forEach
        {
            if let observer = $0.value { observer.deepLinkManager(self, didRegisterDeepLink: deepLink) }
        }
    }

    func invalidateDeeplink()
    {
        deepLink = nil
    }

    func addObserver(_ observer: DeepLinkManagerObserver)
    {
        observers.append(WeakObserver(observer))
    }

    @discardableResult
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {

        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? NSURL
        {
            processUrl(url as URL)
        }

        return true
    }

    @discardableResult
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {

        processUrl(url)

        return true
    }

    func processUrl(_ url: URL)
    {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }

        if urlComponents.path.contains("payment")
        {
            register(deepLink: .paymentCompletion)
        }
    }

    struct WeakObserver
    {
        private(set) weak var value: DeepLinkManagerObserver?

        init (_ value: DeepLinkManagerObserver)
        {
            self.value = value
        }
    }

    private init () {}
}
