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

class AddUsernameAndPasswordRequest: LoginBaseRequest<AddUsernameAndPasswordRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = AddUsernameAndPasswordResponse
    typealias ErrorHandler = LoginAPIDefaultErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/users/me/link_email_password" }
    
    override var authenticationToken: String? { params.accessToken }

    override var specialQueryParameters: QueryParameters
    {
        var queryParams = QueryParameters()

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

extension AddUsernameAndPasswordRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let redirectUri: String?
        let bodyParams: Body
    }

    struct Body: Encodable
    {
        let username: String
        let password: String
        let email: String
        let promoEmailAgreement: Int

        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey
        {
            case username = "username"
            case password = "password"
            case email = "email"
            case promoEmailAgreement = "promo_email_agreement"
        }

        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(username, forKey: CodingKeys.username)
            try container.encode(password, forKey: CodingKeys.password)
            try container.encode(email, forKey: CodingKeys.email)
            try container.encode(promoEmailAgreement, forKey: CodingKeys.promoEmailAgreement)
        }
    }
}
