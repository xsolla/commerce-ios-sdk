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
import Promises

extension LoginAsyncUtility: LoginAsyncUtilitySocialNetworksProtocol
{
    @discardableResult
    func fetchUserLinkedSocialNetworks() -> Promise<Set<SocialNetwork>>
    {
        let api = self.api

        return Promise<Set<SocialNetwork>>
        { fulfill, reject in

            api.getLinkedSocialNetworks
            { result in

                switch result
                {
                    case .success(let socialNetworks): do
                    {
                        let socialNetworks =
                            Set(socialNetworks.compactMap { SocialNetwork(rawValue: $0.socialNetworkName) })
                        fulfill(socialNetworks)
                    }
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func getSocialNetworksLinkingURL(for socialNetwork: SocialNetwork, callbackUrl: String) -> Promise<URL>
    {
        let api = self.api

        return Promise<URL>
        { fulfill, reject in

            api.getSocialNetworkLinkingURL(for: socialNetwork, callbackURL: callbackUrl)
            { result in

                switch result
                {
                    case .success(let url): fulfill(url)
                    case .failure(let error): reject(error)
                }
            }
        }
    }
}
