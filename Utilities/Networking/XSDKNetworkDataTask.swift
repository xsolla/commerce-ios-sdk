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

public class XSDKNetworkDataTask: NetworkTask
{
    public let id: UUID
    public let task: URLSessionDataTask
    public let dateCreated: Date
    public var dateStarted: Date?

    public var state: URLSessionTask.State { task.state }

    public func start()
    {
        dateStarted = Date()
        task.resume()
    }

    public func cancel()
    {
        task.cancel()
    }

    public init(request: URLRequest, session: URLSession, completionHandler: @escaping URLSessionTaskCompletionHandler)
    {
        logger.debug(.initialization, domain: .networking) { String(describing: Self.self) }

        id = UUID()
        dateCreated = Date()
        task = session.dataTask(with: request, completionHandler: completionHandler)
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .networking) { deinitingType }
    }
}
