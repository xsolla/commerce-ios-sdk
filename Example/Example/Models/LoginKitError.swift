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
import XsollaSDKLoginKit

extension LoginKitError: LocalizedError
{
    public var errorDescription: String?
    {
        switch self
        {
            case .failedURLExtraction: return "Failed url extraction"
            case .authCodeExtractionError(let message): return message ?? "Auth code extraction error"
            case .authTokenExtractionError(let message): return message ?? "Auth token extraction error"
            case .networkLinkingError(let message): return message ?? "Network linking error"
            case .invalidRedirectUrl(let message): return message ?? "Invalid redirect url"
            case .invalidToken: return "Invalid token"
            case .unknownError(let message): return message ?? "Unknown error"
        }
    }
}
