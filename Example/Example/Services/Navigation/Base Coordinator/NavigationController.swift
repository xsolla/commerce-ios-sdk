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

class NavigationController: UINavigationController
{
    private(set) var pushMode: PushMode = .push

    /// Sets a mode for the next push request, after push resets to a default mode (.push)
    func setPushMode(_ mode: PushMode)
    {
        pushMode = mode
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        switch pushMode
        {
            case .push: super.pushViewController(viewController, animated: animated)
            case .replaceCurrent: pushReplaceCurrent(viewController: viewController, animated: animated)
            case .replaceAll: pushReplaceAll(viewController: viewController, animated: animated)
        }

        pushMode = .push
    }

    private func pushReplaceCurrent(viewController: UIViewController, animated: Bool = true)
    {
        if animated { addFadeAnimationIfNeeded() }

        let stack = viewControllers.count > 1 ? viewControllers.prefix(upTo: viewControllers.count-1)
                                              : [viewController]

        setViewControllers(Array(stack), animated: false)
    }

    private func pushReplaceAll(viewController: UIViewController, animated: Bool = true)
    {
        if animated { addFadeAnimationIfNeeded() }

        setViewControllers([viewController], animated: false)
    }

    private func addFadeAnimationIfNeeded()
    {
        if viewControllers.isEmpty { return }

        let transition = CATransition()
        transition.duration = 0.15
        transition.type = CATransitionType.fade

        view.layer.add(transition, forKey: nil)
    }

    enum PushMode
    {
        case push
        case replaceCurrent
        case replaceAll
    }
}
