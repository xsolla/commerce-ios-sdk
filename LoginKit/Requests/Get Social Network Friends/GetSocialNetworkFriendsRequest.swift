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

class GetSocialNetworkFriendsRequest: LoginBaseRequest<GetSocialNetworkFriendsRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = GetSocialNetworkFriendsResponse
    typealias ErrorHandler = LoginAPIDefaultErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .get }
    
    override var relativePath: String { "/users/me/social_friends" }
    
    override var authenticationToken: String? { params.accessToken }
    
    override var specialQueryParameters: QueryParameters
    {
        ["platform": params.platform,
        "offset": String(params.offset),
        "limit": String(params.limit),
        "with_xl_uid": String(params.withLoginId)]
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

extension GetSocialNetworkFriendsRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let platform: String
        let offset: Int
        let limit: Int
        let withLoginId: Bool
    }
}
