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

// swiftlint:disable function_parameter_count

import Foundation

class Logger
{
    let queue: DispatchQueue?
    
    let logContext: Bool
    let logTimestamp: Bool
    let dateFormatter: PrecisionDateFormatter
    
    init(configuration: LoggerKitConfigurationProtocol)
    {
        self.queue = configuration.dispatchQueue
        self.logContext = configuration.logContext
        self.logTimestamp = configuration.logTimestamp
        
        self.dateFormatter = PrecisionDateFormatter()
        dateFormatter.formatType = configuration.timeFormatType
    }
}

extension Logger: LoggerProtocol
{
    func log(_ closure: @autoclosure @escaping () -> Any?,
             level: LogLevelProtocol,
             category: LogCategoryProtocol,
             domain: LogDomainProtocol,
             file: StaticString?,
             function: StaticString?,
             line: Int?)
    {
        let date = Date()
        
        if let queue = queue
        {
            queue.async
            {
                self.log(closure: closure,
                         level: level,
                         category: category,
                         domain: domain,
                         file: file,
                         function: function,
                         line: line,
                         date: date)
            }
        }
        else
        {
            log(closure: closure,
                level: level,
                category: category,
                domain: domain,
                file: file,
                function: function,
                line: line,
                date: date)
        }
    }

    private func log(closure: () -> Any?,
                     level: LogLevelProtocol,
                     category: LogCategoryProtocol,
                     domain: LogDomainProtocol,
                     file: StaticString?,
                     function: StaticString?,
                     line: Int?,
                     date: Date)
    {
        guard let closureResult = closure() else { return }
        
        let location = getLogLocation(file: file, function: function, line: line)
        let message = String(describing: closureResult)
        let symbol = level.emojiSymbol.isEmpty ? "" : "\(level.emojiSymbol) "
        let timestamp = logTimestamp ? "\(getFormattedTimestamp(date)) " : ""
        
        let logMessage = String("\(symbol)\(timestamp)\(domain) [\(category)]: \(location)\(message)")

        print(logMessage)
    }
    
    private func getFormattedTimestamp(_ date: Date) -> String
    {
        dateFormatter.string(from: date)
    }
    
    private func getLogLocation(file: StaticString?, function: StaticString?, line: Int?) -> String
    {
        guard
            logContext,
            let file = file,
            let function = function,
            let line = line
        else
            { return "" }
    
        return "(\(sourceFileName(filePath: file)) \(function):\(line)) "
    }
    
    private func sourceFileName(filePath: StaticString) -> String
    {
        let components = filePath.description.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}
