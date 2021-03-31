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

// https://developers.xsolla.com/login-api/methods/oauth-20/generate-jwt/

class GenerateJWTRequest: LoginBaseRequest<GenerateJWTRequest.Params>,
                          APIRequestProtocol
{
    typealias ResponseModel = GenerateJWTResponse
    typealias ErrorHandler  = GenerateJWTErrorHandler
    typealias ErrorModel    = LoginAPIErrorModel
    typealias ErrorType     = LoginAPIError
    typealias Callback      = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/oauth2/token" }
    
    override var defaultHeaders: LoginBaseRequest<Params>.HTTPHeaders
    {
        [
            HTTPHeaderKey.accept: "application/json",
            HTTPHeaderKey.contentType: "application/x-www-form-urlencoded",
            HTTPHeaderKey.acceptCharset: "utf-8"
        ]
    }
    
    override var bodyData: Data?
    {
        var bodyParams =
        [
            "grant_type": params.grantType,
            "client_id": String(params.clientId)
        ]
        
        if let refreshToken = params.refreshToken { bodyParams["refresh_token"] = refreshToken }
        if let clientSecret = params.clientSecret { bodyParams["client_secret"] = clientSecret }
        if let redirectUri = params.redirectUri { bodyParams["redirect_uri"] = redirectUri }
        if let authCode = params.authCode { bodyParams["code"] = authCode }
        
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = bodyParams.map { URLQueryItem(name: $0.key, value: $0.value) }

        return bodyComponents.query?.data(using: .utf8)
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

extension GenerateJWTRequest
{
    struct Params: RequestParams
    {
        let grantType: String
        let clientId: Int
        let refreshToken: String?
        let clientSecret: String?
        let redirectUri: String?
        let authCode: String?
    }
}
