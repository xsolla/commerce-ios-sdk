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

open class APIBaseRequest
{
    public let apiConfiguration: APIConfigurationProtocol

    open var customJSONDecoder: JSONDecoder? { nil }

    open var basePath: String { apiConfiguration.apiBasePath }
    open var relativePath: String { fatalError("The field must be intentionally defined in successor") }
    open var path: String { "\(basePath)\(relativePath)" }
    open var url: URL { createUrl() }
    open var request: URLRequest { createRequest() }

    open var httpMethod: HTTPMethod { fatalError("The field must be intentionally defined in successor") }
    open var timeoutInterval: TimeInterval { 30 }
    open var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }

    /// Creates a URLRequest by applying all parameters and a payload
    open func createRequest() -> URLRequest
    {
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)

        // Base configuration
        request.httpMethod = httpMethod.rawValue

        // Headers
        self.headers.forEach
        { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        // Cookies
        let cookiesString = self.cookies.map { "\($0.key)=\($0.value)" }.joined(separator: ";")
        request.addValue(cookiesString, forHTTPHeaderField: HTTPHeaderKey.cookie)

        // Http body for all requests excepting GET
        if httpMethod != HTTPMethod.get
        {
            request.httpBody = bodyData
        }

        return request
    }

    /// Creates a URL by adding query items if any
    open func createUrl() -> URL
    {
        guard var urlComponents = URLComponents(string: path) else { fatalError("Endpoint path error") }

        let queryItems = self.queryParameters.map
        { key, value in
            return URLQueryItem(name: key, value: String(describing: value))
        }

        if !queryItems.isEmpty { urlComponents.queryItems = queryItems }

        guard let url = urlComponents.url else { fatalError("Endpoint path error") }

        return url
    }

    // MARK: - Query String

    public typealias QueryParameters = [String: String]

    open var specialQueryParameters: QueryParameters { [:] }

    open var queryParameters: QueryParameters
    {
        var parameters = defaultParameters

        parameters.merge(specialQueryParameters) { (_, new) in new }

        return parameters
    }

    public var defaultParameters: QueryParameters { [:] }

    // MARK: - Http Body

    open var bodyParameters: Encodable? { nil }
    open var bodyData: Data? { bodyParameters?.getJSONData(encoder: bodyParametersEncoder) }

    open var bodyParametersEncoder: JSONEncoder?
    {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyEncodingStrategy
        return encoder
    }

    open var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy
    {
        .useDefaultKeys
    }

    // MARK: - Http Headers

    public typealias HTTPHeaders = [String: String]

    open var headers: HTTPHeaders
    {
        var headers = defaultHeaders

        headers.merge(authHeaders) { (_, new) in new }
        headers.merge(specialHeaders) { (_, new) in new }

        return headers
    }

    open var authenticationToken: String? { nil }
    open var authHeaders: HTTPHeaders
    {
        guard let token = authenticationToken else { return [:] }
        return [HTTPHeaderKey.authorization: "Bearer \(token)"]
    }

    open var specialHeaders: HTTPHeaders { [:] }

    open var defaultHeaders: HTTPHeaders
    {
        [
            HTTPHeaderKey.accept: "application/json",
            HTTPHeaderKey.contentType: "application/json",
            HTTPHeaderKey.acceptCharset: "utf-8"
        ]
    }

    // MARK: - Http Cookies

    public typealias Cookies = [String: String]

    open var cookies: Cookies
    {
        var cookies = defaultCookies

        cookies.merge(specialCookies) { (_, new) in new }

        return cookies
    }

    open var specialCookies: Cookies { [:] }
    open var defaultCookies: Cookies { [:] }

    // MARK: - Initialization

    public init(apiConfiguration: APIConfigurationProtocol)
    {
        self.apiConfiguration = apiConfiguration
    }
}

fileprivate extension Encodable
{
    func getJSONData(encoder: JSONEncoder? = nil) -> Data?
    {
        let encoder = encoder ?? JSONEncoder()
        return try? encoder.encode(self)
    }
}
