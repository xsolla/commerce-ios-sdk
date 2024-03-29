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

public protocol LoggerKitFilterProtocol: AnyObject
{
    func shouldLog(filePath: StaticString) -> Bool
    func shouldLog(methodName: StaticString) -> Bool
    func shouldLog(level: LogLevelProtocol) -> Bool
    func shouldLog(category: LogCategoryProtocol) -> Bool
    func shouldLog(domain: LogDomainProtocol) -> Bool
}

extension LoggerKitFilterProtocol
{
    public func shouldLog(filePath: StaticString) -> Bool { false }
    public func shouldLog(methodName: StaticString) -> Bool { false }
    public func shouldLog(level: LogLevelProtocol) -> Bool { false }
    public func shouldLog(category: LogCategoryProtocol) -> Bool { false }
    public func shouldLog(domain: LogDomainProtocol) -> Bool { false }
}
