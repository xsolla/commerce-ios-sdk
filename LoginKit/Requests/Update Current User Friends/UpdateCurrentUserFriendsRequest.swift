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

// https://developers.xsolla.com/login-api/user-account/managed-by-client/user-friends/update-users-friends

class UpdateCurrentUserFriendsRequest: LoginBaseRequest<UpdateCurrentUserFriendsRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = APIEmptyResponse
    typealias ErrorHandler = LoginAPIDefaultErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/users/me/relationships" }
    
    override var authenticationToken: String? { params.accessToken }
    
    override var bodyParameters: Encodable?
    {
        ["action": params.action,
         "user": params.userID]
    }
    
    func handleSuccess(model: ResponseModel, completionHandler: Callback)
    {
        completionHandler(.success(model))
    }
    
    func handleFailure(error: ErrorType, completionHandler: Callback)
    {
        completionHandler(.failure(error))
    }
}

extension UpdateCurrentUserFriendsRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let action: String
        let userID: String
    }
}
