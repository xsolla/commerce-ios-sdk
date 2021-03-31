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

// swiftlint:disable function_parameter_count

class CreateOrderAPIProxy: APIBaseProxy
{
    func createOrder(accessToken: String,
                     projectId: Int,
                     itemSku: String,
                     currency: String?,
                     locale: String?,
                     isSandbox: Bool,
                     paymentProjectSettings: StorePaymentProjectSettings?,
                     customParameters: [String: String]?,
                     completion: @escaping (StoreAPIResult<CreateOrderResponse>) -> Void)
    {
        let bodyParams = CreateOrderRequest.Params.BodyParams(currency: currency,
                                                              locale: locale,
                                                              sandbox: isSandbox,
                                                              settings: paymentProjectSettings,
                                                              customParameters: customParameters)
        let params = CreateOrderRequest.Params(projectId: projectId,
                                               accessToken: accessToken,
                                               itemSKU: itemSku,
                                               bodyParams: bodyParams)
        
        let request = CreateOrderRequest(params: params, apiConfiguration: apiConfiguration)
        
        request.perform
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
}
