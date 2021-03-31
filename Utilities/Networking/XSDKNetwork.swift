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

public class XSDKNetwork
{
    public private(set) var session = XSDKNetworkSession()
    
    public init(sessionConfiguration: URLSessionConfiguration? = URLSessionConfiguration.default)
    {
        logger.debug(.initialization, domain: .networking) { String(describing: Self.self) }
        
        self.session = XSDKNetworkSession(configuration: sessionConfiguration)
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .networking) { deinitingType }
    }
}

extension XSDKNetwork: RequestPerformer
{
    public func perform(request: URLRequest,
                        completionHandler: @escaping URLSessionTaskCompletionHandler) -> NetworkTask
    {
        session.perform(request: request, completionHandler: completionHandler)
    }
}

extension XSDKNetwork
{
    public static let defaultSessionConfiguration: URLSessionConfiguration =
    {
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        
        return configuration
    }()
}
