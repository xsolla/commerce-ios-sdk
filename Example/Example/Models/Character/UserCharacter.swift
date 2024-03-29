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

protocol UserAttributesProvider
{
    var userAttributes: [UnifiedUserAttribute] { get }
}

protocol UserCharacterProtocol: UserAttributesProvider
{
    func fetchUserAttributes()
    func addUserAttributes(_ attributes: [UnifiedUserAttribute])
    func updateUserAttributes(_ attributes: [UnifiedUserAttribute])
    func removeUserAttributes(_ attributes: [UnifiedUserAttribute])
}

class UserCharacter: UserCharacterProtocol
{
    var userAttributes: [UnifiedUserAttribute] = []

    func fetchUserAttributes()
    {
        dependencies.loadStateListener.setState(.loading(nil), animated: true)
        
        dependencies.asyncUtility.fetchUserAttributes()
        .then { userAttributes in self.handleUserAttributesFetchSuccess(userAttributes) }
        .catch { error in self.handleAsyncUtilityFailure(error: error) }
    }

    func addUserAttributes(_ attributes: [UnifiedUserAttribute])
    {
        let asyncUtility = dependencies.asyncUtility

        dependencies.loadStateListener.setState(.loading(nil), animated: true)

        asyncUtility.createPromisesChain()
        .then { asyncUtility.addUserAttributes(attributes) }
        .then { asyncUtility.fetchUserAttributes() }
        .then { userAttributes in self.handleUserAttributesFetchSuccess(userAttributes) }
        .catch { error in self.handleAsyncUtilityFailure(error: error) }
    }

    func updateUserAttributes(_ attributes: [UnifiedUserAttribute])
    {
        let asyncUtility = dependencies.asyncUtility

        dependencies.loadStateListener.setState(.loading(nil), animated: true)

        asyncUtility.createPromisesChain()
        .then { asyncUtility.updateUserAttributes(attributes) }
        .then { asyncUtility.fetchUserAttributes() }
        .then { userAttributes in self.handleUserAttributesFetchSuccess(userAttributes) }
        .catch { error in self.handleAsyncUtilityFailure(error: error) }
    }

    func removeUserAttributes(_ attributes: [UnifiedUserAttribute])
    {
        let asyncUtility = dependencies.asyncUtility

        dependencies.loadStateListener.setState(.loading(nil), animated: true)

        asyncUtility.createPromisesChain()
        .then { asyncUtility.removeUserAttributes(attributes) }
        .then { asyncUtility.fetchUserAttributes() }
        .then { userAttributes in self.handleUserAttributesFetchSuccess(userAttributes) }
        .catch { error in self.handleAsyncUtilityFailure(error: error) }
    }

    func handleUserAttributesFetchSuccess(_ userAttributes: [UnifiedUserAttribute])
    {
        DispatchQueue.main.async
        {
            self.dependencies.customAttributesDataSource.setup(with: userAttributes.filter { !$0.readonly })
            self.dependencies.readonlyAttributesDataSource.setup(with: userAttributes.filter { $0.readonly })
            self.dependencies.loadStateListener.setState(.normal, animated: true)
            self.userAttributes = userAttributes
        }
    }

    func handleAsyncUtilityFailure(error: Error)
    {
        logger.error(.application) { error }

        DispatchQueue.main.async
        {
            self.dependencies.loadStateListener.setState(.error(nil), animated: true)
        }
    }

    // MARK: - Initialization

    let dependencies: Dependencies

    init(dependencies: Dependencies)
    {
        self.dependencies = dependencies
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}

extension UserCharacter
{
    struct Dependencies
    {
        let asyncUtility: CharacterAsyncUtilityProtocol
        let loadStateListener: LoadStatable
        let customAttributesDataSource: UserAttributesListDataSource
        let readonlyAttributesDataSource: UserAttributesListDataSource
    }
}
