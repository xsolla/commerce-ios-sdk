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

class UserAttributeListItemCell: TableViewCell
{
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    var model: Model!

    func setup(model: Model)
    {
        self.model = model

        titleLabel.attributedText = model.title
        subtitleLabel.attributedText = model.subtitle
    }

    override func awakeFromNib()
    {
        super.awakeFromNib()

        let guide = UILayoutGuide()
        contentView.addLayoutGuide(guide)

        NSLayoutConstraint.activate(
        [
            guide.topAnchor.constraint(equalTo: contentView.topAnchor),
            guide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            guide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            guide.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
    }
}

extension UserAttributeListItemCell
{
    static let titleDefaultAttributes: Attributes = Style.notification.attributes(withColor: .xsolla_lightSlateGrey)
    static let subtitleDefaultAttributes: Attributes = Style.heading2.attributes(withColor: .xsolla_white)
}

extension UserAttributeListItemCell
{
    struct Model
    {
        let title: NSAttributedString?
        let subtitle: NSAttributedString?
    }
}
