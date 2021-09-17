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

protocol AuthenticationMainVCProtocol: BaseViewController
{
    var loginRequestHandler: ((LoginVCProtocol, UIView, LoginFormData) -> Void)? { get set }
    var signupRequestHandler: ((SignupVCProtocol, UIView, SignupFormData) -> Void)? { get set }
    var authenticationOptionsRequestHandler: ((LoginVCProtocol, UIView) -> Void)? { get set }

    var socialNetworkLoginRequestHandler: ((LoginVCProtocol, SocialNetwork) -> Void)? { get set }
    var moreSocialNetworksRequestHandler: ((LoginVCProtocol) -> Void)? { get set }

    var privacyPolicyRequestHandler: (() -> Void)? { get set }
    var passwordRecoveryRequestHandler: (() -> Void)? { get set }
}

class AuthenticationMainVC: BaseViewController, AuthenticationMainVCProtocol
{
    var loginRequestHandler: ((LoginVCProtocol, UIView, LoginFormData) -> Void)?
    var signupRequestHandler: ((SignupVCProtocol, UIView, SignupFormData) -> Void)?
    var authenticationOptionsRequestHandler: ((LoginVCProtocol, UIView) -> Void)?

    var socialNetworkLoginRequestHandler: ((LoginVCProtocol, SocialNetwork) -> Void)?
    var moreSocialNetworksRequestHandler: ((LoginVCProtocol) -> Void)?

    var privacyPolicyRequestHandler: (() -> Void)?
    var passwordRecoveryRequestHandler: (() -> Void)?

    var loginVC: LoginVCProtocol!
    var signupVC: SignupVCProtocol!
    var tabbarVC: TabbarViewController!
    
    override var navigationBarIsHidden: Bool? { true }
    
    @IBOutlet private weak var tabbarViewControllerContainer: UIView!

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        guard loginVC != nil, signupVC != nil, tabbarVC != nil else
        {
            fatalError("Either loginVC, signupVC, tabbarVC is not set")
        }

        setupTabbarViewController()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Setup
    
    private func setupTabbarViewController()
    {
        var items: [TabbarViewController.Item] = []
        
        do
        {
            let tabbarItem = UITabBarItem(title: L10n.Auth.Main.Tabs.login,
                                          image: nil,
                                          selectedImage: nil)
            
            let item = TabbarViewController.Item(tabbarItem: tabbarItem, viewController: loginVC)
            items.append(item)
        }
        
        do
        {
            let tabbarItem = UITabBarItem(title: L10n.Auth.Main.Tabs.signup,
                                          image: nil,
                                          selectedImage: nil)
            
            let item = TabbarViewController.Item(tabbarItem: tabbarItem, viewController: signupVC)
            items.append(item)
        }
        
        addChild(tabbarVC)
        tabbarViewControllerContainer.addSubview(tabbarVC.view)
        tabbarVC.view.pinToSuperview()
        tabbarVC.didMove(toParent: self)
        
        tabbarVC.setup(with: items)
        tabbarVC.tabBarLeading = 20
        tabbarVC.tabBarTrailing = 20
        
        setupHandlers()
    }
    
    private func setupHandlers()
    {
        // swiftlint:disable line_length

        loginVC.loginRequestHandler = { [weak self] vc, sender, formData in self?.loginRequestHandler?(vc, sender, formData) }
        loginVC.socialNetworkLoginRequestHandler = { [weak self] vc, network in self?.socialNetworkLoginRequestHandler?(vc, network) }
        loginVC.authenticationOptionsRequestHandler = { [weak self] vc, sender in self?.authenticationOptionsRequestHandler?(vc, sender) }

        loginVC.moreSocialNetworksRequestHandler = { [weak self] vc in self?.moreSocialNetworksRequestHandler?(vc) }
        loginVC.passwordRecoveryRequestHandler = { [weak self] in self?.passwordRecoveryRequestHandler?() }
        loginVC.privacyPolicyRequestHandler = { [weak self] in self?.privacyPolicyRequestHandler?() }

        signupVC.signupRequestHandler = { [weak self] vc, sender, formData in self?.signupRequestHandler?(vc, sender, formData) }
        signupVC.privacyPolicyRequestHandler = { [weak self] in self?.privacyPolicyRequestHandler?() }

        // swiftlint:enable line_length
    }
}
