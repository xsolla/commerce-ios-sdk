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

public protocol AuthCodeExtracting
{
    func extract(from url: URL) -> Result<String, Error>
    func extract(from result: Result<URL, Error>) -> Result<String, Error>
    func extract(from result: Result<String, Error>) -> Result<String, Error>
    func extractError(url: URL) -> Error?
}

public class AuthCodeExtractor: AuthCodeExtracting
{
    public func extract(from url: URL) -> Result<String, Error>
    {
        guard
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value
        else
            { return .failure(extractError(url: url) ?? LoginKitError.authCodeExtractionError("Unknown error")) }

        return .success(code)
    }

    public func extract(from result: Result<URL, Error>) -> Result<String, Error>
    {
        if case let .failure(error) = result { return .failure(error) }

        guard case let .success(url) = result else
        {
            return .failure(LoginKitError.authCodeExtractionError("Unknown error"))
        }

        guard
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value
        else
        {
            return .failure(extractError(url: url) ?? LoginKitError.authCodeExtractionError("Unknown error"))
        }

        return .success(code)
    }

    public func extract(from result: Result<String, Error>) -> Result<String, Error>
    {
        if case .failure(let error) = result { return .failure(error) }

        if case .success(let urlString) = result
        {
            if let url = URL(string: urlString) { return extract(from: .success(url)) }
            else { return .failure(LoginKitError.authCodeExtractionError("Invalid url string")) }
        }

        return .failure(LoginKitError.authCodeExtractionError("Unknown error"))
    }

    public func extractError(url: URL) -> Error?
    {
        guard
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let errorCode = urlComponents.queryItems?.first(where: { $0.name == "error_code" })?.value,
            var errorDescription = urlComponents.queryItems?.first(where: { $0.name == "error_description" })?.value
        else
            { return nil }

        errorDescription = errorDescription.replacingOccurrences(of: "+", with: " ")

        switch errorCode
        {
            case "010-016": return LoginKitError.networkLinkingError(errorDescription)
            default: return LoginKitError.unknownError(errorDescription)
        }
    }
}
