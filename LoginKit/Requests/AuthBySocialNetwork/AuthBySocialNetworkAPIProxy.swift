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

final class AuthBySocialNetworkAPIProxy: LoginBaseAPIProxy
{
    func authBySocialNetwork(oAuth2Params: OAuth2Params,
                             providerName: String,
                             socialNetworkAccessToken: String,
                             socialNetworkAccessTokenSecret: String?,
                             socialNetworkOpenId: String?,
                             completion: @escaping (LoginAPIResult<AuthBySocialNetworkResponse>) -> Void)
    {
        let params = AuthBySocialNetworkRequest.Params(
            providerName: providerName,
            clientId: oAuth2Params.clientId,
            responseType: oAuth2Params.responseType,
            state: oAuth2Params.state,
            redirectUri: oAuth2Params.redirectUri,
            scope: oAuth2Params.scope,
            socialNetworkAccessToken: socialNetworkAccessToken,
            socialNetworkAccessTokenSecret: socialNetworkAccessTokenSecret,
            socialNetworkOpenId: socialNetworkOpenId)
        
        let request = AuthBySocialNetworkRequest(params: params, apiConfiguration: apiConfiguration)
        
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
