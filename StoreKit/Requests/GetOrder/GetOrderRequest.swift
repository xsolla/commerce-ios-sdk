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

// https://developers.xsolla.com/store-api/cart-payment/order/get-order/

class GetOrderRequest: StoreBaseRequest<GetOrderRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = GetOrderResponse
    typealias ErrorHandler = GetOrderErrorHandler
    typealias ErrorModel = StoreAPIErrorModel
    typealias ErrorType = StoreAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler: GetOrderErrorHandler = GetOrderErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .get }
    
    override var relativePath: String { "/v2/project/\(String(params.projectId))/order/\(params.orderId)" }
    
    override var authHeaders: APIBaseRequest.HTTPHeaders
    {
        var headers = [String: String]()
        
        if let accessToken = params.accessToken
        {
            headers[HTTPHeaderKey.authorization] = "Bearer \(accessToken)"
        }
        if let unauthorizedId = params.unauthorizedId
        {
            headers[HTTPHeaderKey.unauthorizedId] = unauthorizedId
        }
        if let unauthorizedUserEmail = params.unauthorizedUserEmail
        {
            headers[HTTPHeaderKey.user] = unauthorizedUserEmail
        }
        
        return headers
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

extension GetOrderRequest
{
    struct Params: RequestParams
    {
        let projectId: Int
        let orderId: String
        
        // for authorized users
        let accessToken: String?
        
        // for unauthorized users (games and physical goods)
        let unauthorizedId: String?
        let unauthorizedUserEmail: String?
    }
}
