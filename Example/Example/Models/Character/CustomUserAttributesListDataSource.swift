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

class CustomUserAttributesListDataSource: UserAttributesListDataSource
{
    let addNewAttributeSectionIndex: Int = 1

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == addNewAttributeSectionIndex { return 1 }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == addNewAttributeSectionIndex
        {
            return getAddNewAttributeCell(at: indexPath, tableView: tableView)
        }

        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    func getAddNewAttributeCell(at indexPath: IndexPath, tableView: UITableView) -> UITableViewCell
    {
        guard indexPath.section == 1 else { fatalError("Wrong section index provided in index path") }

        let cell = tableView.cell(UserAttributeListAddAttributeCell.self, for: indexPath)

        cell.onActionButton = { [weak self] in self?.actionHandler(.add) }

        return cell
    }
}
