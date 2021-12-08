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

// https://developers.xsolla.com/login-api/methods/oauth-20/oauth-20-register-a-new-user/

class RegisterNewUserRequest: LoginBaseRequest<RegisterNewUserRequest.Params>,
                              APIRequestProtocol
{
    typealias ResponseModel = RegisterNewUserResponse
    typealias ErrorHandler  = RegisterNewUserErrorHandler
    typealias ErrorModel    = LoginAPIErrorModel
    typealias ErrorType     = LoginAPIError
    typealias Callback      = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/oauth2/user" }
    
    override var specialQueryParameters: QueryParameters
    {
        var queryParams =
        [
            "response_type": params.responseType,
            "client_id": String(params.clientId),
            "state": params.state
        ]
        
        if let scope = params.scope { queryParams["scope"] = scope }
        if let redirectUri = params.redirectUri { queryParams["redirect_uri"] = redirectUri }
        
        return queryParams
    }
    
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

extension RegisterNewUserRequest
{
    struct Params: RequestParams
    {
        // query params
        let responseType: String
        let clientId: Int
        let state: String
        let scope: String?
        let redirectUri: String?
        let bodyParams: BodyParams
        
        struct BodyParams: Encodable
        {
            let username: String
            let password: String
            let email: String
            let acceptConsent: Bool?
            let fields: [String: String]?
            let promoEmailAgreement: Int?
        }
    }
}
