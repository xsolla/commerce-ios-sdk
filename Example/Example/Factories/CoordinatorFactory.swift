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

// swiftlint:disable line_length

import UIKit

protocol CoordinatorFactoryProtocol
{
    func createMainContainerCoordinator(presenter: Presenter?,
                                        params: MainContainerCoordinator.Params) -> MainContainerCoordinatorProtocol
    
    func createMainContentCoordinator(presenter: Presenter?,
                                      params: MainContentCoordinator.Params) -> MainContentCoordinatorProtocol
    
    func createAuthenticationCoordinator(presenter: Presenter?,
                                         params: AuthenticationCoordinator.Params) -> AuthenticationCoordinatorProtocol
}

class CoordinatorFactory: CoordinatorFactoryProtocol
{
    // MARK: - Public
    
    func createMainContainerCoordinator(presenter: Presenter?,
                                        params: MainContainerCoordinator.Params) -> MainContainerCoordinatorProtocol
    {
        let coordinatorDependencies = MainContainerCoordinator.Dependencies(coordinatorFactory: self,
                                                                            viewControllerFactory: self.params.viewControllerFactory,
                                                                            modelFactory: self.params.modelFactory,
                                                                            xsollaSDK: self.params.xsollaSDK)
        
        let coordinator = MainContainerCoordinator(presenter: presenter,
                                                   dependencies: coordinatorDependencies,
                                                   params: params)
        
        return coordinator
    }
    
    func createMainContentCoordinator(presenter: Presenter?,
                                      params: MainContentCoordinator.Params) -> MainContentCoordinatorProtocol
    {
        let coordinatorDependencies = MainContentCoordinator.Dependencies(coordinatorFactory: self,
                                                                          viewControllerFactory: self.params.viewControllerFactory,
                                                                          datasourceFactory: self.params.datasourceFactory,
                                                                          modelFactory: self.params.modelFactory,
                                                                          store: self.params.store)
        
        let coordinator = MainContentCoordinator(presenter: presenter,
                                                 dependencies: coordinatorDependencies,
                                                 params: params)
        
        return coordinator
    }
    
    func createAuthenticationCoordinator(presenter: Presenter?,
                                         params: AuthenticationCoordinator.Params) -> AuthenticationCoordinatorProtocol
    {
        let coordinatorDependencies = AuthenticationCoordinator.Dependencies(coordinatorFactory: self,
                                                                             viewControllerFactory: self.params.viewControllerFactory,
                                                                             xsollaSDK: self.params.xsollaSDK)
        
        let coordinator = AuthenticationCoordinator(presenter: presenter,
                                                    dependencies: coordinatorDependencies,
                                                    params: params)
        
        return coordinator
    }
    
    // MARK: - Private
    
    private let params: Params
    
    init(params: Params)
    {
        self.params = params
    }
}

extension CoordinatorFactory
{
    struct Params
    {
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let xsollaSDK: XsollaSDKProtocol
        let store: StoreProtocol
    }
}
