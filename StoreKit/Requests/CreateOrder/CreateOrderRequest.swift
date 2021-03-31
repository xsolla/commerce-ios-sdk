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

// https://developers.xsolla.com/store-api/cart-payment/payment/create-order-with-item/

class CreateOrderRequest: StoreBaseRequest<CreateOrderRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = CreateOrderResponse
    typealias ErrorHandler = CreateOrderErrorHandler
    typealias ErrorModel = StoreAPIErrorModel
    typealias ErrorType = StoreAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler: CreateOrderErrorHandler = CreateOrderErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/v2/project/\(String(params.projectId))/payment/item/\(params.itemSKU)" }
    
    override var authenticationToken: String? { params.accessToken }
    
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

extension CreateOrderRequest
{
    struct Params: RequestParams
    {
        let projectId: Int
        let accessToken: String
        let itemSKU: String
        let bodyParams: BodyParams
    }
}

extension CreateOrderRequest.Params
{
    struct BodyParams: Encodable
    {
        let currency: String?
        let locale: String?
        let sandbox: Bool
        let settings: StorePaymentProjectSettings?
        let customParameters: [String: String]?
    }
}
