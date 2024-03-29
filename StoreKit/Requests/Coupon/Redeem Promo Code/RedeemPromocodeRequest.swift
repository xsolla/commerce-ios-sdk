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

// https://developers.xsolla.com/api/igs-bb/operation/redeem-promo-code/

class RedeemPromocodeRequest: StoreBaseRequest<RedeemPromocodeRequest.Params>, APIRequestProtocol
{
    typealias ResponseModel = PromocodeResponse
    typealias ErrorHandler = StoreAPIDefaultErrorHandler
    typealias ErrorModel = StoreAPIErrorModel
    typealias ErrorType = StoreAPIError
    typealias Callback = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .post }
    
    override var relativePath: String { "/v2/project/\(String(params.projectId))/promocode/redeem" }
    
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

extension RedeemPromocodeRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let projectId: Int
        let bodyParams: BodyParams
    }

    struct BodyParams: Encodable
    {
        let promocodeCode: String
        let cart: Cart
        let selectedUnitItems: [String: String]?
        
        enum CodingKeys: String, CodingKey
        {
            case promocodeCode = "coupon_code"
            case cart
            case selectedUnitItems = "selected_unit_items"
        }
        
        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(promocodeCode, forKey: .promocodeCode)
            try container.encode(cart, forKey: .cart)
            if let selectedUnitItems = selectedUnitItems, selectedUnitItems.count > 0
            {
                try container.encode(selectedUnitItems, forKey: .selectedUnitItems)
            }
        }

        struct Cart: Encodable
        {
            let id: String
        }
    }
}
