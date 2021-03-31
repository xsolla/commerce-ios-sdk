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

class VirtualItemCell: TableViewCell
{
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var discountedPriceLabel: UILabel!
    @IBOutlet private weak var priceCurrencyImage: UIImageView!
    @IBOutlet private weak var discountLabel: Label!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var expirationPeriodLabel: UILabel!
    
    @IBOutlet private weak var actionButtonsStackView: UIStackView!
    
    private var actionButton: Button = .init(frame: .zero)
    private var extraActionButton: Button = .init(frame: .zero)

    @IBOutlet private weak var pricesStackView: UIStackView!
    
    var actionHandler: ((VirtualItemsListItemAction) -> Void)?
    var model: Model!
    
    func setup(model: Model)
    {
        self.model = model

        setupLabels()
        setupImageView(image: model.image)
        setupActionButton(action: model.action)
        setupExtraActionButton(action: model.extraAction)
        setupPriceCurrencyView(image: model.currencyImage)
    }
    
    func setupLabels()
    {
        titleLabel.attributedText = model.title
        descriptionLabel.attributedText = model.description
    
        setupPriceLabel(attributedText: model.price)
        setupDiscountedPriceLabel(attributedText: model.discountedPrice)
        setupDiscountLabel(attributedText: model.discount)
        setupExpirationPeriodLabel(attributedText: model.expirationPeriod)
    }
    
    func setupPriceLabel(attributedText: NSAttributedString?)
    {
        priceLabel.attributedText = attributedText
        priceLabel.isHidden = priceLabel.attributedText == nil
    }
    
    func setupDiscountedPriceLabel(attributedText: NSAttributedString?)
    {
        discountedPriceLabel.attributedText = attributedText
        discountedPriceLabel.isHidden = discountedPriceLabel.attributedText == nil
    }
    
    func setupDiscountLabel(attributedText: NSAttributedString?)
    {
        discountLabel.attributedText = attributedText
        discountLabel.isHidden = attributedText == nil
        
        discountLabel.backgroundColor = UIColor.xsolla_inactiveMagenta
        discountLabel.layer.cornerRadius = Shape.smallCornerRadius
        discountLabel.layer.masksToBounds = true
    }
    
    func setupExpirationPeriodLabel(attributedText: NSAttributedString?)
    {
        expirationPeriodLabel.attributedText = attributedText
        expirationPeriodLabel.isHidden = attributedText == nil
    }
    
    func setupActionButton(action: VirtualItemsListItemAction)
    {
        if case .none = action { actionButton.isHidden = true; return }
        else                   { actionButton.isHidden = false }
        
        let attributedTitle = getButtonTitle(for: action).attributed(.label, color: .xsolla_white)
        actionButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func setupExtraActionButton(action: VirtualItemsListItemAction)
    {
        if case .none = action { extraActionButton.isHidden = true; return }
        else                   { extraActionButton.isHidden = false }
        
        let attributedTitle = getButtonTitle(for: action).attributed(.label, color: .xsolla_lightSlateGrey)
        extraActionButton.setAttributedTitle(attributedTitle, for: .normal)
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
    
    func setupPriceCurrencyView(image: Image?)
    {
        guard let image = image else { priceCurrencyImage.isHidden = true; return }
        
        priceCurrencyImage.isHidden = false
        
        if case .image(let image) = image { priceCurrencyImage.image = image }
        
        switch image
        {
            case .image(let image): priceCurrencyImage.image = image
            case .url(let stringUrl): do
            {
                guard let url = URL(string: stringUrl) else
                {
                    priceCurrencyImage.image = nil
                    return
                }
                
                priceCurrencyImage.sd_setImage(with: url)
            }
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        actionButton.setupAppearance(config: Button.smallContained)
        extraActionButton.setupAppearance(config: Button.smallOutlined)
        
        actionButtonsStackView.addArrangedSubview(extraActionButton)
        actionButtonsStackView.addArrangedSubview(actionButton)
        
        actionButton.widthAnchor.constraint(greaterThanOrEqualTo: titleLabel.widthAnchor,
                                            multiplier: 0.5,
                                            constant: -8).isActive = true
        
        extraActionButton.widthAnchor.constraint(greaterThanOrEqualTo: titleLabel.widthAnchor,
                                                 multiplier: 0.5,
                                                 constant: -8).isActive = true
        
        actionButton.setTouchUpInsideHandler { [unowned self] _ in self.actionHandler?(model.action) }
        extraActionButton.setTouchUpInsideHandler { [unowned self] _ in self.actionHandler?(model.extraAction) }
        
        pricesStackView.setCustomSpacing(4, after: priceCurrencyImage)
    }
    
    private func getButtonTitle(for action: VirtualItemsListItemAction) -> String
    {
        switch action
        {
            case .buyWithRealCurrency,
                 .buyWithVirtualCurrency: return L10n.Common.Button.buy
                
            case .previewBundle: return L10n.Common.Button.preview
            
            default: return ""
        }
    }
}

extension VirtualItemCell
{
    struct Model
    {
        let image: Image
        let title: NSAttributedString?
        let price: NSAttributedString?
        let discountedPrice: NSAttributedString?
        let discount: NSAttributedString?
        let description: NSAttributedString?
        let expirationPeriod: NSAttributedString?
        let action: VirtualItemsListItemAction
        let extraAction: VirtualItemsListItemAction
        let currencyImage: Image?
    }
}
