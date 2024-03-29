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

class LinkedSocialNetworksListItemCell: UICollectionViewCell
{
    var tapHandler: (() -> Void)?
    
    func setup(withItem item: Item)
    {
        imageView.image = item.image

        switch item.state
        {
            case .regular: setRegularState()
            case .linked: setLinkedState()
        }
    }

    private let imageView = UIImageView(frame: .zero)
    private let linkActionImageView = UIImageView(frame: .zero)
    private let linkedIndicatorView = UIView(frame: .zero)

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit()
    {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true

        contentView.addSubview(linkedIndicatorView)
        linkedIndicatorView.pinToSuperview()
        linkedIndicatorView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        contentView.addSubview(imageView)
        imageView.pinToSuperview()
        imageView.contentMode = .center

        contentView.addSubview(linkActionImageView)
        linkActionImageView.translatesAutoresizingMaskIntoConstraints = false
        linkActionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        linkActionImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        linkActionImageView.image = Asset.Images.linkSocialNetworkIcon.image

        contentView.addTapHandler { [weak self] in self?.tapHandler?() }
    }

    override func layoutSubviews()
    {
        linkedIndicatorView.layer.cornerRadius = bounds.height/2
    }

    private func setRegularState()
    {
        linkedIndicatorView.isHidden = true
        linkActionImageView.isHidden = false
    }

    private func setLinkedState()
    {
        linkedIndicatorView.isHidden = false
        linkActionImageView.isHidden = true
    }

    // swiftlint:disable nesting
    struct Item
    {
        let image: UIImage
        let state: State

        enum State
        {
            case regular
            case linked
        }
    }
}
