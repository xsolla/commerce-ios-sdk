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

struct SocialNetworksListRow
{
    var socialNetwork: SocialNetwork
    var attributedTitle: NSAttributedString
    var icon: UIImage?
}

protocol SocialNetworksListVCProtocol: BaseViewController
{
    var onSearchTextEdit: ((String) -> Void)? { get set }
    var onRowSelect: ((SocialNetworksListRow) -> Void)? { get set }
    var onDismiss: (() -> Void)? { get set }
    
    func setup(rows: [SocialNetworksListRow])
    func reloadView()
}

class SocialNetworksListVC: BaseViewController, SocialNetworksListVCProtocol
{
    // MARK: - SearchableListVCProtocol
    
    var onSearchTextEdit: ((String) -> Void)?
    var onRowSelect: ((SocialNetworksListRow) -> Void)?
    var onDismiss: (() -> Void)?
    
    func setup(rows: [SocialNetworksListRow])
    {
        self.rows = rows
    }
    
    func reloadView()
    {
        tableView.reloadData()
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    
    // MARK: - Private
    
    private var rows: [SocialNetworksListRow] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupTitleLabel()
        reloadView()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    private func setupTableView()
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(SocialNetworksListCell.self)
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 48
        tableView.backgroundColor = .xsolla_nightBlue
        tableView.contentInset = .init(top: 20, left: 0, bottom: 36, right: 0)
    }
    
    private func setupSearchBar()
    {
        searchBar.delegate = self
        
        searchBar.backgroundColor = .xsolla_black
        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar.searchBarStyle = .minimal
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.xsolla_onSurfaceMedium.cgColor
        searchBar.placeholder = L10n.SocialNetworks.searchPlaceholder
        searchBar.layer.cornerRadius = 6
    }
    
    private func setupTitleLabel()
    {
        titleLabel.attributedText = L10n.SocialNetworks.title.attributed(.heading2, color: .xsolla_white)
    }
    
    @IBAction private func onCancelButton(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
}

extension SocialNetworksListVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: SocialNetworksListCell.reuseIdentifier, for: indexPath)
        
        guard let socialNetworkCell = cell as? SocialNetworksListCell else { return cell }
        
        socialNetworkCell.setup(row: rows[indexPath.row])
        socialNetworkCell.hideDivider()
        
        return socialNetworkCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        onRowSelect?(rows[indexPath.row])
    }
}

extension SocialNetworksListVC: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        onSearchTextEdit?(searchText)
    }
}

protocol SocialNetworksListDataSourceProtocol: AnyObject
{
    func setup(socialNetworksRows: [SocialNetworksListRow])
    func numberOfItems() -> Int
    func getItem(at index: Int) -> SocialNetworksListRow
}

class SocialNetworksListDataSource: SocialNetworksListDataSourceProtocol
{
    var onSocialNetworkSelect: ((SocialNetwork) -> Void)?
    
    func setup(socialNetworksRows: [SocialNetworksListRow])
    {
        self.socialNetworksRows = socialNetworksRows
    }
    
    func numberOfItems() -> Int
    {
        socialNetworksRows.count
    }
    
    func getItem(at index: Int) -> SocialNetworksListRow
    {
        socialNetworksRows[index]
    }
    
    private var socialNetworksRows: [SocialNetworksListRow] = []
}
