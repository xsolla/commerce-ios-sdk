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

class ConnectedDevicesListItemCell: TableViewCell
{
    var buttonHandler: (() -> Void)?
    
    func setup(with model: Model)
    {
        titleLabel.attributedText = model.attributedTitle
        descriptionLabel.attributedText = model.attributedDescription
        button.isEnabled = model.removable
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var button: Button!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews()
    {
        let buttonTitle = L10n.Profile.Section.ConnectedDevices.removeButton
        button.setAttributedTitle(buttonTitle.attributed(.button, color: .xsolla_inactiveWhite), for: .normal)
        button.setAttributedTitle(buttonTitle.attributed(.button, color: .xsolla_inactiveWhite.withAlphaComponent(0.5)),
                                  for: .disabled)
        button.setupAppearance(config: Button.largeOutlined)
        button.contentEdgeInsets = .init(top: 0, left: 28, bottom: 0, right: 28)
        
        button.addTarget(self, action: #selector(onButton), for: .touchUpInside)

        showDivider()
    }
    
    @objc private func onButton()
    {
        buttonHandler?()
    }
}

extension ConnectedDevicesListItemCell
{
    struct Model
    {
        let attributedTitle: NSAttributedString?
        let attributedDescription: NSAttributedString?
        let removable: Bool
    }
}
