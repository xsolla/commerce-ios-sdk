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

class StartAuthByEmailRequest: LoginBaseRequest<StartAuthByEmailRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = StartAuthByEmailResponse
    typealias ErrorHandler = LoginAPIDefaultErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/oauth2/login/email/request" }
    
    override var specialQueryParameters: QueryParameters
    {
        var queryParams = [
            "response_type": params.responseType,
            "client_id": String(params.clientId),
            "state": params.state,
            "locale": params.locale
        ]
        
        if let scope = params.scope { queryParams["scope"] = scope }
        if let redirectUri = params.redirectUri { queryParams["redirect_uri"] = redirectUri }
        
        return queryParams 
    }
    
    override var bodyParameters: Encodable?
    {
       Body(email: params.email, linkUrl: params.linkUrl, sendLink: params.sendLink)
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

extension StartAuthByEmailRequest
{
    struct Params: RequestParams
    {
        let responseType: String
        let clientId: Int
        let scope: String?
        let state: String
        let redirectUri: String?
        let email: String
        let linkUrl: String?
        let sendLink: Bool
        let locale: String?
    }

    // swiftlint:disable nesting

    struct Body: Encodable
    {
        let email: String
        let linkUrl: String?
        let sendLink: Bool

        enum CodingKeys: String, CodingKey
        {
            case email = "email"
            case linkUrl = "link_url"
            case sendLink = "send_link"
        }

        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(email, forKey: .email)
            try container.encodeIfPresent(linkUrl, forKey: .linkUrl)
            try container.encode(sendLink, forKey: .sendLink)
        }
    }
}
