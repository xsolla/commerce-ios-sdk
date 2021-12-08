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

// https://developers.xsolla.com/login-api/user-account/managed-by-client/user-profile/update-user-details

class UpdateCurrentUserDetailsRequest: LoginBaseRequest<UpdateCurrentUserDetailsRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = UpdateCurrentUserDetailsResponse
    typealias ErrorHandler = UpdateCurrentUserDetailsErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .patch }
    
    override var relativePath: String { "/users/me" }
    
    override var authenticationToken: String? { params.accessToken }
    
    override var bodyParameters: Encodable?
    {
        var bodyParams: [String: String] = [:]
        
        if let birhday = params.birthday { bodyParams["birthday"] = birhday }
        if let firstName = params.firstName { bodyParams["first_name"] = firstName }
        if let lastName = params.lastName { bodyParams["last_name"] = lastName }
        if let gender = params.gender { bodyParams["gender"] = gender }
        if let nickname = params.nickname { bodyParams["nickname"] = nickname }
        
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

extension UpdateCurrentUserDetailsRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let birthday: String?
        let firstName: String?
        let lastName: String?
        let gender: String?
        let nickname: String?
    }
}
