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

public struct LogLevel: LogLevelProtocol
{
    public let title: String
    public let level: Int
    public var emojiSymbol: String
    public var description: String { title }

    public static let verbose = Self.init(title: "verbose", level: 0, emojiSymbol: "🟤")
    public static let event = Self.init(title: "event", level: 10, emojiSymbol: "⚫️")
    public static let debug = Self.init(title: "debug", level: 20, emojiSymbol: "🔵")
    public static let info = Self.init(title: "info", level: 30, emojiSymbol: "🟢")
    public static let notice = Self(title: "notice", level: 40, emojiSymbol: "⚪️")
    public static let warning = Self.init(title: "warning", level: 50, emojiSymbol: "🟡")
    public static let error = Self.init(title: "error", level: 100, emojiSymbol: "🔴")

    public init(title: String, level: Int, emojiSymbol: String)
    {
        self.title = title
        self.level = level
        self.emojiSymbol = emojiSymbol
    }
}
