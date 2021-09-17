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

class AppCoordinator: BaseCoordinator<AppCoordinator.Dependencies,
                                      AppCoordinator.Params>
{
    let window: UIWindow
    
    init(window: UIWindow, dependencies: Dependencies, params: Params)
    {
        let viewController = UIViewController()
        let presenter = NavigationController(rootViewController: viewController)
        
        self.window = window
        super.init(presenter: presenter, dependencies: dependencies, params: params)

        setupNavigationBar(in: presenter)

        window.rootViewController = presenter
        window.makeKeyAndVisible()

        dependencies.loginManager.delegate = self
    }
    
    override func start()
    {
        let coordinator = getCoordinator(for: dependencies.appstateProvider.currentState)
        
        presenter?.setPushMode(.replaceAll)
        startChildCoordinator(coordinator) { [unowned self] in self.start() }
    }
    
    private func setupNavigationBar(in navigationController: UINavigationController)
    {

    }
    
    private func getCoordinator(for state: AppState) -> Coordinator
    {
        switch state
        {
            case .authenticating: return getAuthenticationCoordinator()
            case .main: return getMainContainerCoordinator()
        }
    }
    
    private func getAuthenticationCoordinator() -> Coordinator
    {
        let factory = dependencies.factories.coordinatorFactory

        let loginAsyncUtilityParams = LoginAsyncUtilsFactoryParams(clientId: AppConfig.loginClientId,
                                                                   redirectURL: AppConfig.redirectUrl,
                                                                   scope: AppConfig.defaultLoginScope)

        let loginAsyncUtility =
            dependencies.factories.asyncUtilsFactory.createLoginAsyncUtils(params: loginAsyncUtilityParams)

        let params = AuthenticationCoordinatorFactoryParams(loginManager: dependencies.loginManager,
                                                            loginAsyncUtility: loginAsyncUtility)
        
        let coordinator = factory.createAuthenticationCoordinator(presenter: presenter, params: params)
        
        return coordinator
    }
    
    private func getMainContainerCoordinator() -> Coordinator
    {
        let factory = dependencies.factories.coordinatorFactory
        let coordinator = factory.createMainContainerCoordinator(presenter: presenter, params: .none)
        
        coordinator.onLogout = { [unowned self] in self.dependencies.loginManager.logout() }
        
        return coordinator
    }
}

extension AppCoordinator: LoginManagerDelegate
{
    func loginManager(_ loginManager: LoginManagerProtocol, didInvalidateAccessToken withError: LoginManagerError?)
    {
        childCoordinators = []
        start()
    }

    func loginManagerDidLogin(_ loginManager: LoginManagerProtocol)
    {
        childCoordinators = []
        start()
    }
}

extension AppCoordinator
{
    struct Dependencies
    {
        let factories: Factories
        let appstateProvider: AppStateProviderProtocol
        let loginManager: LoginManagerProtocol
    }
    
    typealias Params = EmptyParams
}
