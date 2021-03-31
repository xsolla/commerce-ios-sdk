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

// https://developers.xsolla.com/login-api/methods/oauth-20/jwt-auth-by-username-and-password/

class AuthByUsernameAndPasswordJWTRequest: LoginBaseRequest<AuthByUsernameAndPasswordJWTRequest.Params>,
                                           APIRequestProtocol
{
    typealias ResponseModel = AuthByUsernameAndPasswordJWTResponse
    typealias ErrorHandler  = AuthByUsernameAndPasswordJWTErrorHandler
    typealias ErrorModel    = LoginAPIErrorModel
    typealias ErrorType     = LoginAPIError
    typealias Callback      = (Result<ResponseModel, ErrorType>) -> Void

    let errorHandler = ErrorHandler()

    // MARK: - Request settings

    override var httpMethod: HTTPMethod { .post }

    override var relativePath: String { "/oauth2/login/token" }

    override var specialQueryParameters: QueryParameters
    {
        var queryParams = ["client_id": String(params.clientId)]

        if let scope = params.scope { queryParams["scope"] = scope }

        return queryParams
    }

    override var bodyParameters: Encodable?
    {
        [
            "password": params.password,
            "username": params.username
        ]
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

extension AuthByUsernameAndPasswordJWTRequest
{
    struct Params: RequestParams
    {
        let username: String
        let password: String
        let clientId: Int
        let scope: String?
    }
}
