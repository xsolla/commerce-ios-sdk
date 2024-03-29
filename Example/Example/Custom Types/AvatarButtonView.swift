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

final class AvatarButtonView: BaseView
{
    var primaryImage: UIImage? { didSet { update() } }
    var secondaryImage: UIImage? { didSet { update() } }
    var dimmerColor: UIColor? { didSet { update() } }

    var onTap: ((AvatarButtonView) -> Void)?

    private var primaryImageView = UIImageView(frame: .zero)
    private var secondaryImageView = UIImageView(frame: .zero)
    private var dimmerView = UIView(frame: .zero)

    override func commonInit()
    {
        setupImageViews()
        TapGesture.add(to: self)
        { [weak self] in guard let self = self else { return }
            self.onTap?(self)
        }
        layer.masksToBounds = true
    }

    override func layoutSubviews()
    {
        layer.cornerRadius = bounds.height/2
    }

    private func setupImageViews()
    {
        addSubview(primaryImageView)
        addSubview(dimmerView)
        addSubview(secondaryImageView)

        primaryImageView.pinToSuperview()
        secondaryImageView.pinToSuperview()
        dimmerView.pinToSuperview()

        primaryImageView.contentMode = .scaleAspectFill
        secondaryImageView.contentMode = .center
    }

    private func update()
    {
        primaryImageView.image = primaryImage
        secondaryImageView.image = secondaryImage
        dimmerView.backgroundColor = dimmerColor
    }
}
