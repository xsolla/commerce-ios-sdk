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

// https://developers.xsolla.com/login-api/methods/general/reset-password/

class ResetPasswordRequest: LoginBaseRequest<ResetPasswordRequest.Params>,
                            APIRequestProtocol
{
    typealias ResponseModel = APIEmptyResponse
    typealias ErrorHandler  = ResetPasswordErrorHandler
    typealias ErrorModel    = LoginAPIErrorModel
    typealias ErrorType     = LoginAPIError
    typealias Callback      = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/password/reset/request" }
    
    override var specialQueryParameters: QueryParameters
    {
        var queryParams = ["projectId": params.loginProjectId]
        
        if let loginUrl = params.loginUrl { queryParams["login_url"] = loginUrl }
        
        return queryParams
    }
    
    override var bodyParameters: Encodable? { ["username": params.username] }
    
    func handleSuccess(model: ResponseModel, completionHandler: Callback)
    {
        completionHandler(.success(model))
    }
    
    func handleFailure(error: ErrorType, completionHandler: Callback)
    {
        completionHandler(.failure(error))
    }
}

extension ResetPasswordRequest
{
    struct Params: RequestParams
    {
        let loginProjectId: String
        let username: String
        let loginUrl: String?
    }
}
