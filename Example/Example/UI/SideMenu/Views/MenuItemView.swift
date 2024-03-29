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

class MenuItemView: UIView
{
    var isSelected: Bool = false
    
    var textColorNormal: UIColor = .xsolla_white { didSet { update() } }
    var textColorSelected: UIColor = .xsolla_magenta  { didSet { update() } }
    
    private var title: String
    private var image: UIImage?
    private var selectedImage: UIImage?
        
    let stack: UIStackView
    let titleLabel: UILabel
    let imageView: UIImageView?
    
    init(title: String,
         image: UIImage? = nil,
         selectedImage: UIImage? = nil,
         height: CGFloat? = nil,
         spacing: CGFloat = 28)
    {
        stack = UIStackView(frame: .zero)
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = spacing
        
        self.image = image
        self.selectedImage = selectedImage
        
        if let image = image
        {
            let view = UIImageView(image: image)
            view.heightAnchor.constraint(equalToConstant: 24).isActive = true
            view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            stack.addArrangedSubview(view)
            imageView = view
        }
        else
        {
            imageView = nil
        }
        
        self.title = title
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.attributedText = title.attributed(.button, color: isSelected ? textColorSelected
                                                                                : textColorNormal)

        stack.addArrangedSubview(titleLabel)
        
        super.init(frame: .zero)
        
        addSubview(stack)
        stack.pinToSuperview()
        
        if let height = height
        {
            let heightConstraint = heightAnchor.constraint(equalToConstant: height)
            heightConstraint.isActive = true
        }
    }
    
    private func update()
    {
        titleLabel.attributedText = title.attributed(.button,
                                                     color: isSelected ? textColorSelected : textColorNormal)
    }
    
    override init(frame: CGRect)
    {
        fatalError("init(frame:) has not been implemented, use init(title:image:) instead")
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented, use init(title:image:) instead")
    }
}
