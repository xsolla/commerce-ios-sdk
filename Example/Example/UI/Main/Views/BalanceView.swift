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

class BalanceView: BaseView
{
    var currency1Balance: VirtualCurrencyBalance? { didSet { update() } }
    var currency2Balance: VirtualCurrencyBalance? { didSet { update() } }
    
    var addCurrencyHandler: (() -> Void)?
    var tapHandler: (() -> Void)?
    
    private let currency1IconView = UIImageView()
    private let currency2IconView = UIImageView()
    private let addIcon = UIImageView(image: Asset.Images.balanceAddIcon.image)
    private let currency1Label = UILabel(frame: .zero)
    private let currency2Label = UILabel(frame: .zero)
    
    override func commonInit()
    {
        backgroundColor = .clear
        
        layer.borderColor = UIColor.xsolla_transparentSlateGrey.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = Shape.mediumCornerRadius
        
        addSubview(currency1IconView)
        addSubview(currency2IconView)
        addSubview(currency1Label)
        addSubview(currency2Label)
        addSubview(addIcon)
        
        currency1IconView.translatesAutoresizingMaskIntoConstraints = false
        currency2IconView.translatesAutoresizingMaskIntoConstraints = false
        currency1Label.translatesAutoresizingMaskIntoConstraints = false
        currency2Label.translatesAutoresizingMaskIntoConstraints = false
        addIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
        [
            currency1IconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            currency2IconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            currency1Label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1),
            currency2Label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1),
            addIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            currency1IconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            currency1Label.leadingAnchor.constraint(equalTo: currency1IconView.trailingAnchor, constant: 4),
            currency2IconView.leadingAnchor.constraint(equalTo: currency1Label.trailingAnchor, constant: 16),
            currency2Label.leadingAnchor.constraint(equalTo: currency2IconView.trailingAnchor, constant: 4),
            addIcon.leadingAnchor.constraint(equalTo: currency2Label.trailingAnchor, constant: 16),
            addIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            currency1IconView.widthAnchor.constraint(equalToConstant: 20),
            currency2IconView.widthAnchor.constraint(equalToConstant: 20),
            currency1IconView.heightAnchor.constraint(equalToConstant: 20),
            currency2IconView.heightAnchor.constraint(equalToConstant: 20),
            
            addIcon.widthAnchor.constraint(equalToConstant: 24),
            addIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        addIcon.isUserInteractionEnabled = true
        
        addTapHandler { [weak self] in self?.tapHandler?() }
        addIcon.addTapHandler { [weak self] in self?.addCurrencyHandler?() }
        
        update()
    }
    
    private func update()
    {
        currency1Label.attributedText =
            currency1Balance?.balance.attributed(.description, color: .xsolla_lightSlateGrey)
        
        currency2Label.attributedText =
            currency2Balance?.balance.attributed(.description, color: .xsolla_lightSlateGrey)
        
        currency1IconView.sd_setImage(with: currency1Balance?.iconUrl)
        currency2IconView.sd_setImage(with: currency2Balance?.iconUrl)
    }
}
