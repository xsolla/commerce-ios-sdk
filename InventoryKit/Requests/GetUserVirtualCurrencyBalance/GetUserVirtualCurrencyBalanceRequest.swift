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

// https://developers.xsolla.com/store-api/player-inventory/client/get-user-virtual-balance/

class GetUserVirtualCurrencyBalanceRequest: InventoryBaseRequest<GetUserVirtualCurrencyBalanceRequest.Params>,
                                            APIRequestProtocol
{
    typealias ResponseModel = GetUserVirtualCurrencyBalanceResponse
    typealias ErrorHandler  = GetUserVirtualCurrencyBalanceErrorHandler
    typealias ErrorModel    = InventoryAPIErrorModel
    typealias ErrorType     = InventoryAPIError
    typealias Callback      = (Result<ResponseModel, ErrorType>) -> Void
    
    let errorHandler = ErrorHandler()
    
    // MARK: - Request settings
    
    override var httpMethod: HTTPMethod { .get }
    
    override var relativePath: String { "/v2/project/\(String(params.projectId))/user/virtual_currency_balance" }
    
    override var authenticationToken: String? { params.accessToken }
    
    override var specialQueryParameters: QueryParameters
    {
        var queryParams = [String: String]()
        
        if let platform = params.platform { queryParams["platform"] = platform }
        
        return queryParams
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

extension GetUserVirtualCurrencyBalanceRequest
{
    struct Params: RequestParams
    {
        let accessToken: String
        let projectId: Int
        let platform: String?
    }
}
