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

protocol MainVCProtocol: BaseViewController, VirtualCurrencyBalanceProviderDelegate
{
    var sideMenuRequestHandler: (() -> Void)? { get set }
    var addCurrencyHandler: (() -> Void)? { get set }
}

class MainVC: BaseViewController, MainVCProtocol
{
    // MainVCProtocol
    var sideMenuRequestHandler: (() -> Void)?
    var addCurrencyHandler: (() -> Void)?

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var menuButton: UIButton!
    @IBOutlet private weak var balanceView: BalanceView!
    
    override var navigationBarIsHidden: Bool? { true }

    private var contentNavigationController: NavigationController!
    
    private var currency1Balance: VirtualCurrencyBalance?
    private var currency2Balance: VirtualCurrencyBalance?
    
    func embedNavigationController(_ controller: NavigationController)
    {
        contentNavigationController = controller
        
        embedNavigationController()
    }
    
    func embedNavigationController()
    {
        guard view != nil, let controller = contentNavigationController, controller.parent != self else { return }
        
        addChild(controller)
        containerView.addSubview(controller.view)
        controller.view.pinToSuperview()
        controller.didMove(toParent: self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        embedNavigationController()
        setupBalanceView()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Setup
    
    private func setupBalanceView()
    {
        balanceView.addCurrencyHandler = { [weak self] in self?.addCurrencyHandler?() }
    }
    
    // MARK: - Update
    
    private func updateCurrencyBalanceView()
    {
        guard isViewLoaded else { return }
        balanceView.currency1Balance = currency1Balance
        balanceView.currency2Balance = currency2Balance
    }
    
    // MARK: - Handlers
    
    @IBAction private func onMenuButton(_ sender: UIButton)
    {
        sideMenuRequestHandler?()
    }
}

extension MainVC: VirtualCurrencyBalanceProviderDelegate
{
    func didRecieveCurrencyBalance(currency1Balance: VirtualCurrencyBalance, currency2Balance: VirtualCurrencyBalance)
    {
        self.currency1Balance = currency1Balance
        self.currency2Balance = currency2Balance
        updateCurrencyBalanceView()
    }
}
