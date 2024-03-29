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

protocol UserAttributesListDataSourceProtocol: UITableViewDataSource, UITableViewDelegate
{
    var title: String { get }
    func setup(with items: [UnifiedUserAttribute])
}

class UserAttributesListDataSource: NSObject, UserAttributesListDataSourceProtocol
{
    let title: String
    private var items: [UnifiedUserAttribute] = []

    let actionHandler: ActionHandler

    func item(at index: Int) -> UnifiedUserAttribute
    {
        items[index]
    }

    func setup(with items: [UnifiedUserAttribute])
    {
        self.items = items
    }

    // MARK: - UITableViewDataSource

    var mainSectionIndex: Int { 0 }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == mainSectionIndex { return items.count }

        fatalError("Wrong section index provided")
    }

    func cellForMainSection(at indexPath: IndexPath, tableView: UITableView) -> UITableViewCell
    {
        guard indexPath.section == mainSectionIndex else { fatalError("Wrong section index provided in index path") }

        let cell = tableView.cell(UserAttributeListItemCell.self, for: indexPath)

        let item = items[indexPath.row]
        let attributedTitle = item.key.attributed(UserAttributeListItemCell.titleDefaultAttributes)
        let attributedSubtitle = item.value.attributed(UserAttributeListItemCell.subtitleDefaultAttributes)
        let model = UserAttributeListItemCell.Model(title: attributedTitle, subtitle: attributedSubtitle)

        cell.setup(model: model)

        cell.onTouchEnded = item.readonly ? nil : { [weak self] cell in self?.actionHandler(.edit(item)) }

        if isLastCell(at: indexPath) { cell.hideDivider() }
        else                         { cell.showDivider() }

        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == mainSectionIndex { return cellForMainSection(at: indexPath, tableView: tableView) }

        fatalError("Wrong section index provided in index path")
    }

    func isLastCell(at indexPath: IndexPath) -> Bool
    {
        return indexPath.row == items.count - 1
    }

    init(title: String, actionHandler: @escaping ActionHandler)
    {
        self.title = title
        self.actionHandler = actionHandler

        super.init()
    }
}

extension UserAttributesListDataSource
{
    enum Action
    {
        case add
        case edit(UnifiedUserAttribute)
    }

    typealias ActionHandler = (Action) -> Void
}
