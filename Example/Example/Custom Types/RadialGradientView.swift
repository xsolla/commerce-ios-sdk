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

class RadialGradientView: UIView
{
    var colors: [CGColor] = [UIColor.black.cgColor, UIColor.clear.cgColor] { didSet { update() } }
    var locations: [NSNumber] = [0, 1] { didSet { update() } }
    
    private lazy var radialGradientLayer: CAGradientLayer =
    {
        let gradientlayer = CAGradientLayer()
        
        gradientlayer.type = .radial
        gradientlayer.colors = colors
        gradientlayer.locations = locations
        gradientlayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientlayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.addSublayer(gradientlayer)
        
        return gradientlayer
    }()

    override func layoutSubviews()
    {
        super.layoutSubviews()
        update()
    }
    
    private func update()
    {
        radialGradientLayer.colors = colors
        radialGradientLayer.locations = locations
        radialGradientLayer.frame = bounds
        radialGradientLayer.cornerRadius = bounds.width / 2.0
    }
}
