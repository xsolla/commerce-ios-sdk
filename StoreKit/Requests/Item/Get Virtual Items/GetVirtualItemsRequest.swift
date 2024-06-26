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

// https://developers.xsolla.com/store-api/virtual-items-currency/catalog/get-virtual-items/

class GetVirtualItemsRequest: StoreBaseRequest<GetVirtualItemsRequest.Params>,
                              APIRequestProtocol
{
    typealias ResponseModel = GetVirtualItemsResponse
    typealias ErrorHandler  = StoreAPIDefaultErrorHandler
    typealias ErrorModel    = StoreAPIErrorModel
    typealias ErrorType     = StoreAPIError
    typealias Callback      = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()

    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .get }
    
    override var relativePath: String { "/v2/project/\(String(params.projectId))/items/virtual_items" }
    
    override var specialQueryParameters: QueryParameters
    {
        var queryParams = [String: String]()
        
        if let limit = params.limit { queryParams["limit"] = "\(limit)" }
        if let offset = params.offset { queryParams["offset"] = "\(offset)" }
        if let locale = params.locale { queryParams["locale"] = locale }
        if let country = params.country { queryParams["country"] = country }
        if let withGeo = params.withGeo { queryParams["with_geo"] = "\(withGeo)" }
        
        if let additionalFields = params.additionalFields
        {
            queryParams["additional_fields"] = additionalFields.joined(separator: ",")
        }
        
        return queryParams
    }

    override var authenticationToken: String? { params.accessToken }

    func handleSuccess(response: URLResponse?, model: ResponseModel, completionHandler: Callback)
    {
        guard let httpResponse = response as? HTTPURLResponse else 
        {
            completionHandler(.success(model))
            return
        }
        
        let languageCode = httpResponse.allHeaderFields["X-User-Locale-Code"] as? String
        let countryCode = httpResponse.allHeaderFields["X-User-Country-Code"] as? String
        
        completionHandler(.success(ResponseModel(hasMore: model.hasMore, items: model.items, languageCode: languageCode, countryCode: countryCode)))
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

extension GetVirtualItemsRequest
{
    struct Params: RequestParams
    {
        let accessToken: String?
        let projectId: Int
        let limit: Int?
        let offset: Int?
        let locale: String?
        let additionalFields: [String]?
        let country: String?
        let withGeo: Int?
    }
}
