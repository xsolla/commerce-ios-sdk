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

protocol ConnectedDevicesListVCProtocol: BaseViewController, LoadStatable
{
    var removeDeviceHandler: ((ConnectedDevicesListItem) -> Void)? { get set }
    
    func setup(with dataSource: ConnectedDevicesListDataSourceProtocol)
}

class ConnectedDevicesListVC: BaseViewController, ConnectedDevicesListVCProtocol
{
    override var navigationBarIsHidden: Bool? { false }

    var loadState: LoadState = .normal
    private var activityVC: ActivityIndicatingViewController?

    var removeDeviceHandler: ((ConnectedDevicesListItem) -> Void)?
    
    func setup(with dataSource: ConnectedDevicesListDataSourceProtocol)
    {
        self.dataSource = dataSource
        dataSource.removeDeviceHandler = { [weak self] item in self?.removeDeviceHandler?(item) }

        guard isViewLoaded else { return }

        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var dataSource: ConnectedDevicesListDataSourceProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupTableView()

        title = L10n.Profile.Section.connectedDevices
    }
    
    private func setupTableView()
    {
        tableView.dataSource = dataSource
        tableView.registerXib(for: ConnectedDevicesListItemCell.self)
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
}

extension ConnectedDevicesListVC: LoadStatable
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

extension ConnectedDevicesListVC: EmbeddableControllerContainerProtocol
{
    func getContaiterViewForEmbeddableViewController() -> UIView?
    {
        view
    }
}
