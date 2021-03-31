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

// swiftlint:disable function_parameter_count

import Foundation
import XsollaSDKUtilities

class InventoryAPIResponseProcessor
{
    typealias InventoryAPIError = APIError<InventoryAPIErrorModel>
    
    let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder())
    {
        logger.debug(.initialization, domain: .inventoryKit) { String(describing: Self.self) }
        
        self.decoder = decoder
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .inventoryKit) { deinitingType }
    }
}

extension InventoryAPIResponseProcessor: ResponseProcessor
{
    func process<ResponseModel: Decodable>(response: URLResponse?,
                                           data: Data?,
                                           request: URLRequest,
                                           error: Error?,
                                           errorHandler: APIErrorHandlerProtocol,
                                           decoder: JSONDecoder?) -> Result<ResponseModel, Error>
    {
        let decoder = decoder ?? self.decoder
        
        // Network error
        if let error = error
        {
            if (error as NSError).code == NSURLErrorCancelled { return .failure(XSDKNetworkError.cancelled(error)) }
            else                                              { return .failure(XSDKNetworkError.networkingError(error)) } // swiftlint:disable:this line_length
        }
        
        // Server code related error
        if let error: InventoryAPIError = errorHandler.error(request: request,
                                                             response: response as? HTTPURLResponse,
                                                             data: data,
                                                             decoder: decoder)
        {
            return .failure(error)
        }
        
        // Null data error
        if data == nil { return .failure(InventoryAPIError.emptyData) }
        
        // Empty response
        if
            let data = data, data.count == 0,
            let modelType = ResponseModel.self as? EmptyResponseDecodable.Type,
            let model = modelType.init() as? ResponseModel
        {
            return .success(model)
        }
        
        // Model decoding attempt
        do { return .success(try decoder.decode(ResponseModel.self, from: data!)) }
            
        // Decoding error
        catch let error
        {
            #if DEBUG
                
            logger.error(.networking, domain: .inventoryKit)
            {
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }

                return "Decoding error, raw json:\n\(json)"
            }

            #endif

            return .failure(InventoryAPIError.decoding(error))
        }
    }
}
