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

class GetClientUserAttributesRequest: LoginBaseRequest<GetClientUserAttributesRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = GetClientUserAttributesResponse
    typealias ErrorHandler = GetClientUserAttributesErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/attributes/users/me/get" }
    
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

extension GetClientUserAttributesRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let bodyParams: Body
    }
    
    struct Body: Encodable
    {
        let keys: [String]?
        let publisherProjectId: Int?
        let userId: String?
        
        enum CodingKeys: String, CodingKey
        {
            case keys = "keys"
            case publisherProjectId = "publisher_project_id"
            case userId = "user_id"
        }
        
        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(keys, forKey: .keys)
            try container.encodeIfPresent(publisherProjectId, forKey: .publisherProjectId)
            try container.encodeIfPresent(userId, forKey: .userId)
        }
    }
}
