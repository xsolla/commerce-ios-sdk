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

public struct LogCategory: LogCategoryProtocol
{
    public let title: String
    public let emojiSymbol: String
    public var description: String { title }
    
    /// Common, default category, used when particular category is not set
    public static let common = Self.init(title: "Common")
    
    public static let initialization = Self.init(title: "Init")
    public static let deinitialization = Self.init(title: "Deinit")
    public static let networking = Self.init(title: "Networking")
    public static let navigation = Self.init(title: "Navigation")
    public static let ui = Self.init(title: "UI")
    public static let debug = Self.init(title: "Debug")
    
    public init(title: String, emojiSymbol: String = "")
    {
        self.title = title
        self.emojiSymbol = emojiSymbol
    }
}
