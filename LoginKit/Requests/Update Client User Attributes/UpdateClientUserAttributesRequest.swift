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
// swiftlint:disable redundant_string_enum_value

import Foundation
import XsollaSDKUtilities

class UpdateClientUserAttributesRequest: LoginBaseRequest<UpdateClientUserAttributesRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = APIEmptyResponse
    typealias ErrorHandler = LoginAPIDefaultErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/attributes/users/me/update" }
    
    override var authenticationToken: String? { params.accessToken }
    
    override var bodyParameters: Encodable? { params.bodyParams }
    
    func handleSuccess(model: ResponseModel, completionHandler: Callback)
    {
        completionHandler(.success(model))
    }
    
    func handleFailure(error: ErrorType, completionHandler: Callback)
    {
        completionHandler(.failure(error))
    }
}

extension UpdateClientUserAttributesRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let bodyParams: Body
    }
    
    struct Body: Encodable
    {
        let attributes: [Attribute]?
        let publisherProjectId: Int?
        let removingKeys: [String]?
        
        enum CodingKeys: String, CodingKey
        {
            case attributes = "attributes"
            case publisherProjectId = "publisher_project_id"
            case removingKeys = "removing_keys"
        }
        
        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(attributes, forKey: .attributes)
            try container.encode(publisherProjectId, forKey: .publisherProjectId)
            try container.encode(removingKeys, forKey: .removingKeys)
        }
    }
}

extension UpdateClientUserAttributesRequest.Body
{
    struct Attribute: Encodable
    {
        let key: String
        let permission: String?
        let value: String

        enum CodingKeys: String, CodingKey
        {
            case key = "key"
            case permission = "permission"
            case value = "value"
        }

        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(key, forKey: .key)
            try container.encode(permission, forKey: .permission)
            try container.encode(value, forKey: .value)
        }
    }
}
