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

// https://developers.xsolla.com/login-api/user-account/managed-by-client/user-profile/upload-user-picture

class UploadUserPictureRequest: LoginBaseRequest<UploadUserPictureRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = UploadUserPictureResponse
    typealias ErrorHandler = UploadUserPictureErrorHandler
    typealias ErrorModel = LoginAPIErrorModel
    typealias ErrorType = LoginAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    let multipartDataBoundary = "Boundary-\(UUID().uuidString)"
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/users/me/picture" }
    
    override var authenticationToken: String? { params.accessToken }
    
    override var defaultHeaders: HTTPHeaders
    {
        [
            HTTPHeaderKey.accept: "application/json",
            HTTPHeaderKey.contentType: "multipart/form-data; boundary=\(multipartDataBoundary)",
            HTTPHeaderKey.acceptCharset: "utf-8"
        ]
    }
    
    override var bodyData: Data?
    {
        do
        {
            return try createMultipartBody(fileURL: params.imageURL,
                                           fileDataPartParameterName: "picture",
                                           boundary: multipartDataBoundary)
        }
        catch let error
        {
            logger.error { "Cannot create multipart body data with error: \(error.localizedDescription)" }
            return nil
        }
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

extension UploadUserPictureRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let imageURL: URL
    }
}
