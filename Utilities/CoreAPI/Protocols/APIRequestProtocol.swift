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

public protocol APIRequestProtocol
{
    /// API request processing error type
    typealias ErrorType = Error

    associatedtype ResponseModel: Decodable
    associatedtype ErrorHandler: APIErrorHandlerProtocol
    associatedtype ErrorModel: APIDecodableErrorModelProtocol

    associatedtype Callback

    var apiConfiguration: APIConfigurationProtocol { get }
    var request: URLRequest { get }

    var customJSONDecoder: JSONDecoder? { get }
    var errorHandler: ErrorHandler { get }

    func perform(completionHandler: Callback) -> NetworkTask
    func handleSuccess(model: ResponseModel, completionHandler: Callback)
    func handleFailure(error: ErrorType, completionHandler: Callback)
}

extension APIRequestProtocol
{
    @discardableResult
    public func perform(completionHandler: Callback) -> NetworkTask
    {
        let request = self.request
        let processor = apiConfiguration.responseProcessor

        let task = apiConfiguration.requestPerformer.perform(request: request)
        { (data, response, error) in

            let result: Result<ResponseModel, ErrorType> = processor.process(response: response,
                                                                             data: data,
                                                                             request: request,
                                                                             error: error,
                                                                             errorHandler: errorHandler,
                                                                             decoder: customJSONDecoder)
            switch result
            {
                case .success(let model): do
                {
                    DispatchQueue.main.async { self.handleSuccess(model: model, completionHandler: completionHandler) }
                }

                case .failure(let error): do
                {
                    logger.error(.networking, domain: .coreAPI) { error }
                    DispatchQueue.main.async { self.handleFailure(error: error, completionHandler: completionHandler) }
                }
            }
        }

        return task
    }
}
