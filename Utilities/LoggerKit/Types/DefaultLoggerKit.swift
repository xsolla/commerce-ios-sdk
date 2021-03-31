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

/// Wrapper class for LoggerKit. It provides extended API for convenient use. Usually you use it directly, or you can
/// use it as a template/example for your own APIs.
public class DefaultLoggerKit
{
    private let logger: LoggerKit

    public func log(_ closure: @autoclosure @escaping () -> Any?,
                    level: LogLevel = .info,
                    category: LogCategory = .common,
                    domain: LogDomain = .common,
                    file: StaticString? = #file,
                    function: StaticString? = #function,
                    line: Int? = #line)
    {
        logger.log(closure,
                   level: level,
                   category: category,
                   domain: domain,
                   file: file,
                   function: function,
                   line: line)
    }

    public func verbose(_ category: LogCategory = .common,
                        domain: LogDomain = .common,
                        file: StaticString? = #file,
                        function: StaticString? = #function,
                        line: Int? = #line,
                        closure: @escaping () -> Any?)
    {
        log(closure, level: .verbose, category: category, domain: domain, file: file, function: function, line: line)
    }

    public func event(_ category: LogCategory = .common,
                      domain: LogDomain = .common,
                      file: StaticString? = #file,
                      function: StaticString? = #function,
                      line: Int? = #line,
                      closure: @escaping () -> Any?)
    {
        log(closure, level: .event, category: category, domain: domain, file: file, function: function, line: line)
    }

    public func debug(_ category: LogCategory = .common,
                      domain: LogDomain = .common,
                      file: StaticString? = #file,
                      function: StaticString? = #function,
                      line: Int? = #line,
                      closure: @escaping () -> Any?)
    {
        log(closure, level: .debug, category: category, domain: domain, file: file, function: function, line: line)
    }

    public func info(_ category: LogCategory = .common,
                     domain: LogDomain = .common,
                     file: StaticString? = #file,
                     function: StaticString? = #function,
                     line: Int? = #line,
                     closure: @escaping () -> Any?)
    {
        log(closure, level: .info, category: category, domain: domain, file: file, function: function, line: line)
    }

    public func notice(_ category: LogCategory = .common,
                       domain: LogDomain = .common,
                       file: StaticString? = #file,
                       function: StaticString? = #function,
                       line: Int? = #line,
                       closure: @escaping () -> Any?)
    {
        log(closure, level: .notice, category: category, domain: domain, file: file, function: function, line: line)
    }

    public func warning(_ category: LogCategory = .common,
                        domain: LogDomain = .common,
                        file: StaticString? = #file,
                        function: StaticString? = #function,
                        line: Int? = #line,
                        closure: @escaping () -> Any?)
    {
        log(closure, level: .warning, category: category, domain: domain, file: file, function: function, line: line)
    }

    public func error(_ category: LogCategory = .common,
                      domain: LogDomain = .common,
                      file: StaticString? = #file,
                      function: StaticString? = #function,
                      line: Int? = #line,
                      closure: @escaping () -> Any?)
    {
        log(closure, level: .error, category: category, domain: domain, file: file, function: function, line: line)
    }

    public init(configurator: LoggerKitConfiguratorProtocol)
    {
        self.logger = LoggerKit(configurator: configurator)
    }
}
