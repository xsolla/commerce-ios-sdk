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

protocol CharacterAsyncUtilityProtocol: AnyObject, PromisesChainCreatable
{
    func fetchUserAttributes() -> Promise<[UnifiedUserAttribute]>
    func addUserAttributes(_ attributes: [UnifiedUserAttribute]) -> Promise<Void>
    func updateUserAttributes(_ attributes: [UnifiedUserAttribute]) -> Promise<Void>
    func removeUserAttributes(_ attributes: [UnifiedUserAttribute]) -> Promise<Void>
}

class CharacterAsyncUtility: CharacterAsyncUtilityProtocol
{
    func fetchUserAttributes() -> Promise<[UnifiedUserAttribute]>
    {
        return Promise<[UnifiedUserAttribute]>
        { fulfill, reject in

            all(self.fetchCustomUserAttributes(), self.fetchReadonlyUserAttributes())
            .then
            { customAttributes, readonlyAttributes in
                fulfill(customAttributes + readonlyAttributes)
            }
            .catch
            { error in
                reject(error)
            }
        }
    }

    func fetchCustomUserAttributes() -> Promise<[UnifiedUserAttribute]>
    {
        let api = self.api

        return Promise<[UnifiedUserAttribute]>
        { fulfill, reject in

            api.getClientUserAttributes(keys: nil,
                                        publisherProjectId: self.projectId,
                                        userId: self.userDetailsProvider.userDetails?.id)
            { result in

                switch result
                {
                    case .success(let attributes): do
                    {
                        let unifiedAttributes = attributes.map
                        {
                            UnifiedUserAttribute(key: $0.key,
                                                 value: $0.value,
                                                 permission: $0.permission,
                                                 readonly: false)
                        }

                        fulfill(unifiedAttributes)
                    }

                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func fetchReadonlyUserAttributes() -> Promise<[UnifiedUserAttribute]>
    {
        let api = self.api

        return Promise<[UnifiedUserAttribute]>
        { fulfill, reject in

            api.getClientUserReadOnlyAttributes(keys: nil,
                                                publisherProjectId: self.projectId,
                                                userId: self.userDetailsProvider.userDetails?.id)
            { result in

                switch result
                {
                    case .success(let attributes): do
                    {
                        let unifiedAttributes = attributes.map
                        {
                            UnifiedUserAttribute(key: $0.key,
                                                 value: $0.value,
                                                 permission: $0.permission,
                                                 readonly: true)
                        }

                        fulfill(unifiedAttributes)
                    }

                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func addUserAttributes(_ attributes: [UnifiedUserAttribute]) -> Promise<Void>
    {
        updateUserAttributes(attributes)
    }

    func updateUserAttributes(_ attributes: [UnifiedUserAttribute]) -> Promise<Void>
    {
        let api = self.api

        return Promise<Void>
        { fulfill, reject in

            let userAttributes =
                attributes.map { UserAttribute(key: $0.key, value: $0.value, permission: $0.permission) }

            api.updateClientUserAttributes(attributes: userAttributes,
                                           publisherProjectId: self.projectId,
                                           removingKeys: nil)
            { result in

                switch result
                {
                    case .success: fulfill(())
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func removeUserAttributes(_ attributes: [UnifiedUserAttribute]) -> Promise<Void>
    {
        let api = self.api

        return Promise<Void>
        { fulfill, reject in

            let keys = attributes.map { $0.key }

            api.updateClientUserAttributes(attributes: nil, publisherProjectId: self.projectId, removingKeys: keys)
            { result in

                switch result
                {
                    case .success: fulfill(())
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    // MARK: - Initialization

    let api: XsollaSDKProtocol
    let projectId: Int
    let userDetailsProvider: UserProfileDetailsProvider

    init(api: XsollaSDKProtocol, projectId: Int, userDetailsProvider: UserProfileDetailsProvider)
    {
        self.api = api
        self.projectId = projectId
        self.userDetailsProvider = userDetailsProvider
    }
}
