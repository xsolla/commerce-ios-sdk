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

// swiftlint:disable type_name

import Foundation
import AuthenticationServices

@available(iOS 13.4, *)
public class WebAuthenticationSession
{
    public typealias PresentationContextProviding = ASWebAuthenticationPresentationContextProviding

    let url: URL
    let scheme: String
    let completionHandler: (Result<URL, Error>) -> Void
    let presentationContextProvider: ASWebAuthenticationPresentationContextProviding

    var webAuthenticationSession: ASWebAuthenticationSession?
    var retainer: WebAuthenticationSession?

    func start()
    {
        retainer = self
        
        webAuthenticationSession = ASWebAuthenticationSession(url: url,
                                                              callbackURLScheme: scheme,
                                                              completionHandler:
        { [weak self] url, error in

            var result: Result<URL, Error> = .failure(WebAuthenticationSessionError.unknown)

            if let url = url { result = .success(url) }

            if let error = error
            {
                // Unprocessed error
                result = .failure(error)

                // ASWebAuthenticationSessionError
                if (error as NSError).domain == ASWebAuthenticationSessionErrorDomain
                {
                    switch (error as NSError).code
                    {
                        case 1: result = .failure(WebAuthenticationSessionError.canceledLogin)
                        case 2: result = .failure(WebAuthenticationSessionError.presentationContextNotProvided)
                        case 3: result = .failure(WebAuthenticationSessionError.presentationContextInvalid)
                        
                        default: result = .failure(error)
                    }
                }
            }

            self?.completionHandler(result)
            self?.retainer = nil
        })

        webAuthenticationSession?.presentationContextProvider = presentationContextProvider
        webAuthenticationSession?.start()
    }

    func cancel()
    {
        webAuthenticationSession?.cancel()
        retainer = nil
    }

    init(url: URL,
         callbackScheme: String,
         presentationContextProvider: ASWebAuthenticationPresentationContextProviding,
         completionHandler: @escaping (Result<URL, Error>) -> Void)
    {
        self.url = url
        self.scheme = callbackScheme
        self.presentationContextProvider = presentationContextProvider
        self.completionHandler = completionHandler
    }

    enum WebAuthenticationSessionError: Error
    {
        case unknown
        case canceledLogin
        case presentationContextNotProvided
        case presentationContextInvalid
    }
}

@available(iOS 13.4, *)
open class WebAuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding
{
    let presentationAnchor: UIWindow

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor
    {
        presentationAnchor
    }

    public init(presentationAnchor: UIWindow)
    {
        self.presentationAnchor = presentationAnchor
    }
}
