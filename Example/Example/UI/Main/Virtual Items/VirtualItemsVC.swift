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

protocol VirtualItemsVCProtocol: BaseViewController, LoadStatable { }

class VirtualItemsVC: BaseViewController, VirtualItemsVCProtocol
{
    // LoadStatable
    private var loadState: LoadState = .normal
    
    weak var dataSource: VirtualItemsListDataSourceProtocol?
    weak var viewControllerFactory: ViewControllerFactoryProtocol?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tabbarViewControllerContainer: UIView!
    
    private var tabbarChildViewControllers: [UIViewController] = []
    private var activityVC: ActivityIndicatingViewController?
    
    var tabbarVC: TabbarViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        titleLabel.attributedText = L10n.VirtualItems.title.attributed(.heading1, color: .xsolla_white)
        
        setupTabbarViewController()
    }
    
    // MARK: - Setup
    
    private func setupTabbarViewController()
    {
        addChild(tabbarVC)
        tabbarViewControllerContainer.addSubview(tabbarVC.view)
        tabbarVC.view.pinToSuperview()
        tabbarVC.didMove(toParent: self)
        
        tabbarVC.tabBarLeading = 0
        tabbarVC.tabBarTrailing = 0
    }
    
    private func updateTabbarViewController()
    {
        tabbarVC.setup(with: getTabbarItems())
    }
    
    private func getTabbarItems() -> [TabbarViewController.Item]
    {
        guard let dataSource = dataSource, let factory = viewControllerFactory else { return [] }
        
        var items: [TabbarViewController.Item] = []
        let groups = dataSource.getGroups()
        
        for group in groups
        {
            let viewController = factory.createTableviewVC(params: .none)
            let groupDataSource = dataSource.getGroupDatasource(for: group.index)
            
            guard let tableView = viewController.tableView else { continue }
            
            tableView.dataSource = groupDataSource
            tableView.delegate = groupDataSource
            tableView.registerXib(for: VirtualItemCell.self)
            tableView.showsHorizontalScrollIndicator = false
            tableView.showsVerticalScrollIndicator = true
            tableView.separatorStyle = .none

            items.append(TabbarViewController.Item(title: group.name, viewController: viewController))
        }
        
        return items
    }
}

// MARK: - State

extension VirtualItemsVC: LoadStatable
{
    func getState() -> LoadState
    {
        loadState
    }

    func setState(_ state: LoadState, animated: Bool)
    {
        loadState = state
        updateLoadState(animated)
    }

    func updateLoadState(_ animated: Bool = false)
    {
        switch loadState
        {
            case .normal, .error: do
            {
                updateTabbarViewController()
                activityVC?.hide(animated: true)
                activityVC = nil
            }
            
            case .loading: do
            {
                guard activityVC == nil else { return }
                activityVC = ActivityIndicatingViewController.presentEmbedded(in: self, embeddingMode: .over)
            }
        }
    }
}

extension VirtualItemsVC: EmbeddableControllerContainerProtocol
{
    func getContaiterViewForEmbeddableViewController() -> UIView?
    {
        tabbarVC.view
    }
}
