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

public class LoggerKit
{
    private let store: LoggerStoreProtocol
    private let configuration: LoggerKitConfigurationProtocol

    public init(configurator: LoggerKitConfiguratorProtocol)
    {
        configuration = configurator.configuration
        store = configurator.createStore()
    }

    public func log(_ closure: @autoclosure @escaping () -> Any?,
                    level: LogLevelProtocol,
                    category: LogCategoryProtocol,
                    domain: LogDomainProtocol,
                    file: StaticString? = #file,
                    function: StaticString? = #function,
                    line: Int? = #line)
    {
        let filter = configuration.filter

        guard
            filter.shouldLog(level: level),
            filter.shouldLog(category: category),
            filter.shouldLog(domain: domain),
            filter.shouldLog(methodName: function ?? ""),
            filter.shouldLog(filePath: file ?? "")
        else
            { return }

        if let logger = store.getLogger()
        {
            logger.log(closure,
                       level: level,
                       category: category,
                       domain: domain,
                       file: file,
                       function: function,
                       line: line)
        }
    }
}
