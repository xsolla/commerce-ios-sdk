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
import XsollaSDKLoginKit

class DemoUserCreationHelper
{
    func createDemoUser(completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        let url = URL(string: "https://us-central1-xsolla-sdk-demo.cloudfunctions.net/generateDemoUserToken")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request)
        { data, _, error in

            if let error = error
            {
                completion(.failure(error))
                return
            }

            guard let data = data else
            {
                completion(.failure(DemoUserCreationHelperError.invalidData))
                return
            }

            do
            {
                let responseModel = try JSONDecoder().decode(AccessTokenInfo.self, from: data)
                completion(.success(responseModel))
            }
            catch let error
            {
                completion(.failure(error))
                return
            }
        }.resume()
    }

    static let shared = DemoUserCreationHelper()
    private init() {}

}

extension DemoUserCreationHelper
{
    struct AccessTokenInfo: Decodable
    {
        let accessToken: String
        let expiresIn: Int?
        let refreshToken: String?
        let tokenType: String

        enum CodingKeys: String, CodingKey
        {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
            case tokenType = "token_type"
        }
    }
}

extension DemoUserCreationHelper
{
    enum DemoUserCreationHelperError: Error
    {
        case invalidData
    }
}
