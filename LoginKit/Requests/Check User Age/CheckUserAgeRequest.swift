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

// https://developers.xsolla.com/login-api/user-account/managed-by-client/user-profile/check-users-age/

class CheckUserAgeRequest: LoginBaseRequest<CheckUserAgeRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = CheckUserAgeResponse
    typealias ErrorHandler = LoginAPIDefaultErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/users/age/check" }
    
    override var authenticationToken: String? { params.accessToken }

    override var bodyParameters: Encodable?
    {
        let bodyParams: [String: String] =
        [
            "dob": params.birthday,
            "project_id": params.loginId
        ]

        return bodyParams
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

extension CheckUserAgeRequest
{
    struct Params: RequestParams
    {
        let birthday: String
        let accessToken: String
        let loginId: String
    }
}
