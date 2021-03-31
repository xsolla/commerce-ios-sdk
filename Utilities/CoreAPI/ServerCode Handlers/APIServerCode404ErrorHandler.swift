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

// swiftlint:disable line_length

import Foundation

open class APIServerCode404ErrorHandler: APIServerCodeErrorHandler
{
    public var code: Int { 404 } // 404 Not Found

    open func error<ErrorModel: APIDecodableErrorModelProtocol>(data: Data?, decoder: JSONDecoder? = JSONDecoder()) -> APIError<ErrorModel>?
    {
        guard let data = data else { return .notFound("\(code): \(APIErrorTemplateMessages.descriptionEmptyData)", nil) }

        if let errorModel = try? decoder!.decode(ErrorModel.self, from: data)
        {
            return .notFound(errorModel.description, errorModel)
        }

        return .notFound("\(code): \(APIErrorTemplateMessages.descriptionUnprocessed)", nil)
    }

    public init() {}
}
