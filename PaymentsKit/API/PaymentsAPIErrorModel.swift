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

// swiftlint:disable nesting

import Foundation
import XsollaSDKUtilities

struct PaymentsAPIErrorModel: Codable
{
    let error: ErrorModel
    
    struct ErrorModel: Codable
    {
        let code: Int
        let description: String
        
        enum CodingKeys: String, CodingKey
        {
            case code
            case description
        }
        
        init(from decoder: Decoder) throws
        {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            description = try values.decode(String.self, forKey: .description)
            
            let codeString = try values.decode(String.self, forKey: .code)
            
            code = try type(of: self).parsed(code: codeString)
        }
        
        private static func parsed(code: String) throws -> Int
        {
            let trimmedCode = code.replacingOccurrences(of: "-", with: "")
                                  .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let result = Int(trimmedCode) { return result }
            
            throw DecoderError.stringToIntParsingFailure
        }
        
        enum DecoderError: Error
        {
            case stringToIntParsingFailure
        }
    }
}

extension PaymentsAPIErrorModel: APIDecodableErrorModelProtocol
{
    var code: Int { error.code }
    var description: String { error.description }
    var extendedDescription: String { error.description }
}
