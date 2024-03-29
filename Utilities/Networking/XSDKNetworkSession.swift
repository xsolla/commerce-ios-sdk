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

public class XSDKNetworkSession
{
    private(set) var session: URLSession!

    public weak var delegate: URLSessionDataDelegate? { didSet { invalidateAndCancel() } }
    public var delegateQueue: OperationQueue? { didSet { invalidateAndCancel() } }
    public var configuration: URLSessionConfiguration? { didSet { invalidateAndCancel() } }

    public func perform(request: URLRequest,
                        completionHandler: @escaping URLSessionTaskCompletionHandler) -> NetworkTask
    {
        if !valid { initializeSession() }

        let task = XSDKNetworkDataTask(request: request, session: session, completionHandler: completionHandler)
        task.start()

        return task
    }

    public func invalidateAndCancel()
    {
        session?.invalidateAndCancel()
        session = nil
    }

    // MARK: - Private

    private var valid: Bool
    {
        session != nil
    }

    private func initializeSession()
    {
        session = URLSession(configuration: configuration ?? URLSessionConfiguration.default,
                             delegate: delegate,
                             delegateQueue: delegateQueue)
    }

    init(delegate: URLSessionDataDelegate? = nil,
         delegateQueue: OperationQueue? = nil,
         configuration: URLSessionConfiguration? = nil)
    {
        logger.debug(.initialization, domain: .networking) { String(describing: Self.self) }

        self.delegate = delegate
        self.delegateQueue = delegateQueue
        self.configuration = configuration
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .networking) { deinitingType }
    }
}
