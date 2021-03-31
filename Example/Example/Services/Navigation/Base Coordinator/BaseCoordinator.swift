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

class BaseCoordinator<Dependencies, Params>: NSObject, Coordinator, UINavigationControllerDelegate
{
    private(set) var presenter: Presenter?
    let dependencies: Dependencies
    let params: Params
    
    /// ViewController on which dismissal a coordinator is supposed to be finished
    var startViewController: UIViewController?
    
    weak var initialViewController: UIViewController?
    
    /// Parent Coordinator
    var parent: Coordinator?

    /// Coordinator did finish handler
    var onFinish: ((Coordinator) -> Void)?
    
    /// Child coordinators
    var childCoordinators = [Coordinator]()
    
    func start() {}
    
    func finish()
    {
        if let controller = initialViewController { presenter?.popToViewController(controller, animated: true) }
        
        onFinish?(self)
    }
    
    func startChildCoordinator(_ coordinator: Coordinator, onFinish: (() -> Void)? = nil)
    {
        coordinator.onFinish =
        { [unowned self] coordinator in

            self.removeChildCoordinator(coordinator)
            onFinish?()
        }
        
        childCoordinators.append(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    private func removeChildCoordinator(_ coordinator: Coordinator)
    {
        for (index, item) in childCoordinators.enumerated() where coordinator === item
        {
            childCoordinators.remove(at: index)
            break
        }
    }
    
    func pushViewController(_ viewController: UIViewController,
                            animated: Bool = true,
                            pushMode: NavigationController.PushMode = .push)
    {
        var mode = pushMode
        
        // Overriding local push mode by global mode if global one is not default mode (.push)
        if let presenter = presenter, presenter.pushMode != .push { mode = presenter.pushMode }
        
        if startViewController == nil || mode != .push { startViewController = viewController }
        
        if mode != presenter?.pushMode { presenter?.setPushMode(mode) }
        presenter?.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool = true)
    {
        let viewController = presenter?.popViewController(animated: animated)
        
        if viewController != nil, startViewController != nil, viewController == startViewController
        {
            onFinish?(self)
        }
    }
    
    func presentViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)?)
    {
        presenter?.present(viewController, animated: animated, completion: completion)
    }
    
    @objc
    func shouldPassToChildCoordinators(navigationController: UINavigationController,
                                       didShow viewController: UIViewController, animated: Bool) -> Bool
    {
        var dismissedViewController: UIViewController?
        
        if let hiddenViewController = navigationController.transitionCoordinator?.viewController(forKey: .from)
        {
            dismissedViewController = navigationController.children.contains(hiddenViewController)
                                    ? nil
                                    : hiddenViewController
        }
        
        if let dismissed = dismissedViewController, let start = startViewController, dismissed == start
        {
            onFinish?(self)
            return false
        }
        
        return true
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool)
    {
        guard shouldPassToChildCoordinators(navigationController: navigationController,
                                            didShow: viewController, animated: animated)
        else { return }
        
        for coordinator in self.childCoordinators
        {
            guard let coordinator = coordinator as? UINavigationControllerDelegate else { continue }
            
            coordinator.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
    }
    
    init(presenter: Presenter?, dependencies: Dependencies, params: Params)
    {
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
        
        self.dependencies = dependencies
        self.params = params
        self.initialViewController = presenter?.viewControllers.last
        
        super.init()
        
        self.presenter = presenter
        if presenter?.children.count == 0
        {
            presenter?.delegate = self
        }
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}
