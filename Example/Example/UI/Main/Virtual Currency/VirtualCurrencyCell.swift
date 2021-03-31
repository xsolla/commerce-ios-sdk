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
import SDWebImage

class VirtualCurrencyCell: TableViewCell
{
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var discountedPriceLabel: UILabel!
    @IBOutlet private weak var discountLabel: Label!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!
    
    var actionHandler: ((VirtualCurrencyItemAction) -> Void)?
    var model: Model!
    
    func setup(model: Model)
    {
        titleLabel.attributedText = model.title
        priceLabel.attributedText = model.price
        discountedPriceLabel.attributedText = model.discountedPrice
        descriptionLabel.attributedText = model.description
        
        setupDiscountLabel(attributedText: model.discount)
        setupImageView(image: model.image)
        setupActionButton(action: model.action)
        
        self.model = model
    }
    
    func setupDiscountLabel(attributedText: NSAttributedString?)
    {
        discountLabel.attributedText = attributedText
        discountLabel.isHidden = attributedText == nil
        
        discountLabel.backgroundColor = UIColor.xsolla_magenta.withAlphaComponent(0.6)
        discountLabel.layer.cornerRadius = Shape.smallCornerRadius
        discountLabel.layer.masksToBounds = true
    }
    
    func setupActionButton(action: VirtualCurrencyItemAction)
    {
        if case .none = action { actionButton.isHidden = true; return }
        else                   { actionButton.isHidden = false }
        
        let title = L10n.Common.Button.buy
        let attributedTitle = title.attributed(.label, color: .xsolla_white)
        actionButton.setAttributedTitle(attributedTitle, for: .normal)
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

extension VirtualCurrencyCell
{
    struct Model
    {
        let image: Image
        let title: NSAttributedString?
        let price: NSAttributedString?
        let discountedPrice: NSAttributedString?
        let discount: NSAttributedString?
        let description: NSAttributedString?
        let action: VirtualCurrencyItemAction
    }
}
