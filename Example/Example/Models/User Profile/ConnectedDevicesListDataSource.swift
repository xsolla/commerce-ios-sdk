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

protocol ConnectedDevicesListDataSourceProtocol: UITableViewDataSource
{
    var removeDeviceHandler: ((ConnectedDevicesListItem) -> Void)? { get set }
}

struct ConnectedDevicesListItem
{
    let attributedTitle: NSAttributedString?
    let attributedDescription: NSAttributedString?
    let deviceId: String
    let removable: Bool
}

class ConnectedDevicesListDataSource: NSObject, ConnectedDevicesListDataSourceProtocol
{
    var removeDeviceHandler: ((ConnectedDevicesListItem) -> Void)?

    private var items: [ConnectedDevicesListItem]

    init(items: [ConnectedDevicesListItem])
    {
        self.items = items
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = items[indexPath.row]
        let cell = tableView.cell(ConnectedDevicesListItemCell.self, for: indexPath)
        let cellModel = ConnectedDevicesListItemCell.Model(attributedTitle: item.attributedTitle,
                                              attributedDescription: item.attributedDescription,
                                              removable: item.removable)
        cell.setup(with: cellModel)
        cell.buttonHandler = { [weak self] in self?.removeDeviceHandler?(item) }

        return cell
    }
}
