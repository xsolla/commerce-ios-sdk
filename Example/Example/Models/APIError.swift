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
import XsollaSDKUtilities

extension APIError: LocalizedError
{
    public var errorDescription: String?
    {
        switch self
        {
            case .noContent: return "No content in response"
            case .badRequest(let string, _): return string
            case .unauthorized(let string, _): return string
            case .forbidden(let string, _): return string
            case .notFound(let string, _): return string
            case .methodNotAllowed(let string, _): return string
            case .requestTimeout(let string, _): return string
            case .parameters(let string, _): return string
            case .tooManyRequests: return "Too many requests"
            case .emptyData: return "Empty data in response"
            case .decoding: return "Error decoding response"
            case .unknown: return "Unknown error"
        }
    }
}
