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

public enum APIError<ErrorModel: APIDecodableErrorModelProtocol>: Error
{
    /// 204 No Content
    case noContent

    /// 400 Bad request
    case badRequest(String, ErrorModel?)
    /// 401 Unauthorized
    case unauthorized(String, ErrorModel?)
    /// 403 Forbidden
    case forbidden(String, ErrorModel?)
    /// 404 Not Found
    case notFound(String, ErrorModel?)
    /// 405 Method Not Allowed
    case methodNotAllowed(String, ErrorModel?)
    /// 422 Unprocessable Entity
    case parameters(String, ErrorModel?)

    /// 429 Too Many Requests
    case tooManyRequests

    /// No data in the response, server code 200 Ok
    case emptyData

    /// JSON decoding error
    case decoding(Error?)

    /// Unknown unprocessed error
    case unknown(Error?)
}

public enum APIErrorTemplateMessages
{
    public static let descriptionUnprocessed = "Unprocessed error"
    public static let descriptionEmptyData = "Empty error data"
}
