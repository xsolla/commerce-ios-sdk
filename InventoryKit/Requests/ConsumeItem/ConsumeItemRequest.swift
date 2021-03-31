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

// https://developers.xsolla.com/store-api/inventory-client/consume-item/

class ConsumeItemRequest: InventoryBaseRequest<ConsumeItemRequest.Params>,
                          APIRequestProtocol
{
    typealias ResponseModel = APIEmptyResponse
    typealias ErrorHandler  = ConsumeItemErrorHandler
    typealias ErrorModel    = InventoryAPIErrorModel
    typealias ErrorType     = InventoryAPIError
    typealias Callback      = (Result<ResponseModel, ErrorType>) -> Void

    let errorHandler = ErrorHandler()

    // MARK: - Request settings

    override var httpMethod: HTTPMethod { .post }

    override var relativePath: String { "/v2/project/\(String(params.projectId))/user/inventory/item/consume" }

    override var authenticationToken: String? { params.accessToken }

    override var specialQueryParameters: QueryParameters
    {
        var queryParams = [String: String]()

        if let platform = params.platform { queryParams["platform"] = platform }

        return queryParams
    }

    override var bodyParameters: Encodable?
    {
        let body = Body(sku: params.itemSku, quantity: params.itemQuantity, instanceId: params.instanceId)
        return body
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

extension ConsumeItemRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let projectId: Int
        let platform: String?
        let itemSku: String
        let itemQuantity: Int?
        let instanceId: String?
    }

    private struct Body: Encodable
    {
        let sku: String
        let quantity: Int?
        let instanceId: String?

        enum CodingKeys: String, CodingKey
        {
            case sku = "sku"
            case quantity = "quantity"
            case instanceId = "instance_id"
        }

        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(sku, forKey: .sku)
            try container.encode(quantity, forKey: .quantity)
            try container.encode(instanceId, forKey: .instanceId)
        }
    }
}
