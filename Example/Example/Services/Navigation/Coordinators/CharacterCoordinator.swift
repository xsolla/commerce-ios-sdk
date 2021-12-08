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

import UIKit

protocol CharacterCoordinatorProtocol: Coordinator, Finishable { }

class CharacterCoordinator: BaseCoordinator<CharacterCoordinator.Dependencies,
                                            CharacterCoordinator.Params>,
                            CharacterCoordinatorProtocol
{
    private var userCharacter: UserCharacterProtocol?

    override func start()
    {
        showStartVC()
    }

    func showStartVC()
    {
        let actionHandler: UserAttributesListDataSource.ActionHandler =
        { [weak self] action in

            switch action
            {
            case .add: self?.showAttributeEditorScreen(userAttribute: nil)
            case .edit(let attribute): self?.showAttributeEditorScreen(userAttribute: attribute)
            }
        }

        let datasourceFactory = dependencies.datasourceFactory

        let customDataSource =
            datasourceFactory.createUserAttributesListDataSource(params: .custom(actionHandler: actionHandler))

        let readonlyDataSource =
            datasourceFactory.createUserAttributesListDataSource(params: .readonly(actionHandler: actionHandler))

        // View controller
        let characterVCdParams = CharacterVCFactoryParams(customDataSource: customDataSource,
                                                          readonlyDataSource: readonlyDataSource,
                                                          userProfile: dependencies.userProfile)
        let viewController = dependencies.viewControllerFactory.createCharacterVC(params: characterVCdParams)

        // Model
        let userCharacterParams = UserCharacterBuildParams(projectId: AppConfig.projectId,
                                                           userDetailsProvider: dependencies.userProfile,
                                                           loadStateListener: viewController,
                                                           customAttributesDataSource: customDataSource,
                                                           readonlyAttributesDataSource: readonlyDataSource)

        let userCharacter = dependencies.modelFactory.createUserCharacter(params: userCharacterParams)

        userCharacter.fetchUserAttributes()

        self.userCharacter = userCharacter

        pushViewController(viewController)
    }

    func showAttributeEditorScreen(userAttribute: UnifiedUserAttribute? = nil)
    {
        let viewController =
            dependencies.viewControllerFactory.createAttributeEditorVC(params: .init(userAttribute: userAttribute))

        viewController.saveAttributeRequestHandler =
        { [weak self] attributeEditorVC in

            guard
                let attribute = attributeEditorVC.userAttribute,
                let userCharacter = self?.userCharacter
            else
            { return }

            userCharacter.updateUserAttributes([attribute])
            attributeEditorVC.dismiss(animated: true)
        }

        viewController.removeAttributeRequestHandler =
        { [weak self] attributeEditorVC in

            guard
                let attribute = attributeEditorVC.userAttribute,
                let userCharacter = self?.userCharacter
            else
            { return }

            userCharacter.removeUserAttributes([attribute])
            attributeEditorVC.dismiss(animated: true)
        }

        presentViewController(viewController, completion: nil)
    }
}

extension CharacterCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let userProfile: UserProfileProtocol
    }

    struct Params
    {
        let xsollaSDK: XsollaSDKProtocol
    }
}
