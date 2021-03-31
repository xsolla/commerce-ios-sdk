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

// swiftlint:disable nesting

import UIKit
import SDWebImage

class InventoryCell: TableViewCell
{
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!

    var actionHandler: ((InventoryItemAction) -> Void)?
    var model: Model!
    
    func setup(model: Model)
    {
        self.model = model

        titleLabel.attributedText = model.title
        subtitleLabel.attributedText = model.subtitle
        
        setupImageView(image: model.image)
        setupActionButton(action: model.action)
    }
    
    func setupActionButton(action: InventoryItemAction)
    {
        if case .none = action { actionButton.isHidden = true; return }
        else                   { actionButton.isHidden = false }
        
        let title = actionButtonTitle(for: action)
        let attributedTitle = title.attributed(.label, color: .xsolla_white)
        actionButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func actionButtonTitle(for action: InventoryItemAction) -> String
    {
        switch action
        {
            case .consume: return L10n.Common.Button.consume
            case .buyAgain: return L10n.Common.Button.buyAgain
            case .none: return ""
        }
    }
    
    func setupImageView(image: Image)
    {
        if case .image(let image) = image { titleImageView.image = image }
        
        switch image
        {
            case .image(let image): titleImageView.image = image
            case .url(let stringUrl): do
            {
                guard let url = URL(string: stringUrl) else
                {
                    titleImageView.image = Asset.Images.imagePlaceholder.image
                    return
                }
                
                titleImageView.sd_setImage(with: url)
            }
        }
        
        titleImageView.alpha = model.imageState == .dimmed ? 0.5 : 1
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        actionButton.setupAppearance(config: Button.smallContained)
    }
    
    @IBAction private func onActionButton(_ sender: UIButton)
    {
        actionHandler?(model.action)
    }
}

extension InventoryCell
{
    struct Model
    {
        let image: Image
        let imageState: ImageState
        let title: NSAttributedString?
        let subtitle: NSAttributedString?
        let action: InventoryItemAction
    
        enum ImageState
        {
            case normal
            case dimmed
        }
    }
}
