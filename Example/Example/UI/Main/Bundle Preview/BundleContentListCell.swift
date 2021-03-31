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

class BundleContentListCell: TableViewCell
{
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var expirationPeriodLabel: UILabel!
    
    var model: Model!
    
    func setup(model: Model)
    {
        titleLabel.attributedText = model.title
        amountLabel.attributedText = model.amount
        descriptionLabel.attributedText = model.description
        
        expirationPeriodLabel.attributedText = model.expirationPeriod
        expirationPeriodLabel.isHidden = expirationPeriodLabel.attributedText == nil
        
        setupImageView(image: model.image)
        
        self.model = model
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
    }
}

extension BundleContentListCell
{
    struct Model
    {
        let image: Image
        let title: NSAttributedString?
        let amount: NSAttributedString?
        let description: NSAttributedString?
        let expirationPeriod: NSAttributedString?
    }
}
