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

class TableViewCell: UITableViewCell
{
    // Divider view
    let dividerView = UIView(frame: .zero)
    var dividerLeading: CGFloat { 20 }
    var dividerTrailing: CGFloat { 20 }
    var dividerHeight: CGFloat { 0.5 }
    var dividerColor: UIColor { .xsolla_lightSlateGrey }

    var onTouchBegan: ((TableViewCell) -> Void)?
    var onTouchEnded: ((TableViewCell) -> Void)?

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        selectedBackgroundView = UIView(frame: .zero)
    }
    
    private func addDividerView()
    {
        contentView.addSubview(dividerView)
        
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        dividerView.heightAnchor.constraint(equalToConstant: dividerHeight).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                             constant: dividerLeading).isActive = true
                                             
        dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                              constant: -dividerTrailing).isActive = true
                                                      
        dividerView.backgroundColor = dividerColor
    }
    
    private func removeDividerView()
    {
        dividerView.removeFromSuperview()
    }
    
    func showDivider(update: Bool = false)
    {
        if update { removeDividerView() }
        
        if dividerView.superview == nil { addDividerView() }
        contentView.bringSubviewToFront(dividerView)
    }
    
    func hideDivider()
    {
        if dividerView.superview != nil { removeDividerView() }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        onTouchBegan?(self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        onTouchEnded?(self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesCancelled(touches, with: event)
        onTouchEnded?(self)
    }
}
