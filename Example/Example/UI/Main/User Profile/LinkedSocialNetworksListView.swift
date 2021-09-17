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

class LinkedSocialNetworksListView: BaseView
{
    var selectionHandler: ((SocialNetwork) -> Void)?

    func setup(withItems items: [ListItem])
    {
        self.items = items
        collectionView.reloadData()
    }

    private let iconBuilder = IconBuilder(regularColor: .xsolla_white, linkedColor: .xsolla_nightBlue)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let flowLayout = UICollectionViewFlowLayout()

    private var items: [ListItem] = []

    struct ListItem
    {
        let socialNetwork: SocialNetwork
        let linked: Bool
    }

    override func commonInit()
    {
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 52, height: 52)

        addSubview(collectionView)

        collectionView.pinToSuperview()
        collectionView.setCollectionViewLayout(flowLayout, animated: false)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView()

        collectionView.registerCell(LinkedSocialNetworksListItemCell.self)
    }
}

extension LinkedSocialNetworksListView: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.cell(LinkedSocialNetworksListItemCell.self, for: indexPath)

        let item = items[indexPath.item]
        let icon = iconBuilder.getIcon(forSocialNetwork: item.socialNetwork, linked: item.linked)
        let cellItem = LinkedSocialNetworksListItemCell.Item(image: icon, state: item.linked ? .linked : .regular)
        
        cell.setup(withItem: cellItem)

        cell.tapHandler = item.linked ? nil : { [weak self] in self?.selectionHandler?(item.socialNetwork) }

        return cell
    }
}

extension LinkedSocialNetworksListView
{
    class IconBuilder
    {
        private let regularColor: UIColor
        private let linkedColor: UIColor

        private let cache = NSCache<NSString, UIImage>()

        func getIcon(forSocialNetwork network: SocialNetwork, linked: Bool) -> UIImage
        {
            let key = getKey(forSocialNetwork: network, linked: linked)

            if let icon = cache.object(forKey: key) { return icon }

            let icon = network.icon(colored: linked ? linkedColor : regularColor)
            cache.setObject(icon, forKey: key)

            return icon
        }

        private func getKey(forSocialNetwork network: SocialNetwork, linked: Bool) -> NSString
        {
            "\(network)-\(linked ? "linked" : "regular")" as NSString
        }

        init(regularColor: UIColor, linkedColor: UIColor)
        {
            self.regularColor = regularColor
            self.linkedColor = linkedColor
        }
    }
}
