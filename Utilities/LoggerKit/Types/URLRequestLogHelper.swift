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

public struct URLRequestLogHelper: CustomStringConvertible
{
    public var description: String { createDescription() }

    private let request: URLRequest?
    private let data: Data?
    private let response: URLResponse?
    private let error: Error?
    private let mode: Mode
    private var includedKeywords: [String] = []
    private var excludedKeywords: [String] = []
    private var requestTime: CFAbsoluteTime?

    public init?(request: URLRequest?,
                 data: Data? = nil,
                 response: URLResponse? = nil,
                 error: Error? = nil,
                 mode: Mode = .normal,
                 includedKeywords: [String] = [],
                 excludedKeywords: [String] = [],
                 requestTime: CFAbsoluteTime? = nil)
    {
        if let url = request?.url?.absoluteString
        {
            // If the URL contains at least one word from the list of exceptions.
            if excludedKeywords.contains(where: url.contains) { return nil }

            // If the inclusion list exists, but does not contain what you need.
            if includedKeywords.count > 0, !includedKeywords.contains(where: url.contains) { return nil }
        }

        self.request = request
        self.data = data
        self.response = response
        self.error = error
        self.mode = mode
        self.requestTime = requestTime
    }

    func createDescription() -> String
    {
        var description = commonInfo()

        description += "\n"
        description += requestDescription()
        description += responseDescription()
        description += dataDescription()
        description += errorDescription()
        description += "\n"

        return description
    }

    // MARK: - Common info

    func commonInfo() -> String
    {
        var description = ""
        description += requestMethod()
        description += serverCode()
        description += requestDuration()
        description += dataSize()

        return description
    }

    func requestDuration() -> String
    {
        guard let requestTime = requestTime else { return "" }

        let timeElapsed = CFAbsoluteTimeGetCurrent() - requestTime

        return ", duration: \(timeElapsed)s"
    }

    func requestMethod() -> String
    {
        return request?.httpMethod?.uppercased() ?? ""
    }

    func dataSize() -> String
    {
        guard let data = data else { return "" }

        return ", data size: \(formatSize(of: data))"
    }

    func serverCode() -> String
    {
        guard let response = response as? HTTPURLResponse else { return "" }

        return ", status code: \(response.statusCode)"
    }

    // MARK: - Request

    func requestDescription() -> String
    {
        guard
            let request = request,
            let url = request.url?.absoluteString
        else
            { return "" }

        var description = ""
        description += "--- REQUEST --------------------------------------------------\n"
        description += "\(url)\n"
        description += requestBody()

        return description
    }

    func requestBody() -> String
    {
        guard
            mode.rawValue < Mode.compact.rawValue,
            let body = request?.httpBody,
            let string = string(from: body)
        else
        { return "" }

        return "\(string)\n"
    }

    // MARK: - Data

    func dataDescription() -> String
    {
        guard
            mode.rawValue < Mode.compact.rawValue,
            let data = data,
            let string = string(from: data),
            !string.isEmpty
        else
        { return "" }

        var description = ""
        description += "--- RECEIVED DATA --------------------------------------------\n"
        description += "\(string)\n"

        return description
    }

    func string(from data: Data) -> String?
    {
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
            let decodedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let string = String(data: decodedData, encoding: .utf8)
        else
        { return String(data: data, encoding: .utf8) }

        return string
    }

    // MARK: - Response

    func responseDescription() -> String
    {
        guard
            mode.rawValue < Mode.normal.rawValue,
            let response = response
        else
        { return "" }

        var description = ""
        description += "--- RESPONSE -------------------------------------------------\n"
        description += "\(response.description)\n"

        return description
    }

    // MARK: - Error

    func errorDescription() -> String
    {
        guard
            let error = error
        else
        { return "" }

        var description = ""
        description += "--- ERROR ----------------------------------------------------\n"
        description += "\(error.localizedDescription)\n"

        return description
    }

    private func available(for request: URLRequest,
                           includedKeywords: [String],
                           excludedKeywords: [String]) -> Bool
    {
        guard let url = request.url?.absoluteString else { return false }

        // If the URL contains at least one keyword from the exclusion list.
        if excludedKeywords.contains(where: url.contains) { return false }

        // If the URL contains at least one keyword from the inclusion list.
        if includedKeywords.contains(where: url.contains) { return true }

        // If the include list is not empty and the URL doesn't contain any keywords from the list.
        return includedKeywords.count > 0 ? false : true
    }

    // MARK: - Size formatter

    static var byteCountFormatter: ByteCountFormatter =
    {
        let bcf = ByteCountFormatter()
        bcf.countStyle = .memory

        return bcf
    }()

    func formatSize(of data: Data) -> String
    {
        Self.byteCountFormatter.string(fromByteCount: Int64(data.count))
    }
}

extension URLRequestLogHelper
{
    public enum Mode: Int
    {
        case verbose
        case normal
        case compact
    }
}
