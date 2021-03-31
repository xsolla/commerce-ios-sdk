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

import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class Button: MDCButton
{
    var heightConstraint: NSLayoutConstraint!
    
    private var touchUpInsideHandler: ((Button) -> Void)?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit()
    {
        heightConstraint = heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.isActive = true
        heightConstraint.priority = .defaultHighest
        isUppercaseTitle = false
    }
    
    func setupAppearance(config: ButtonAppearanceConfigProtocol)
    {
        heightConstraint.constant = config.height
        
        switch config.schemeType
        {
            case .contained: applyContained(scheme: config.scheme)
            case .outlined: applyOutlined(scheme: config.scheme)
            case .text: applyText(scheme: config.scheme)
        }

        titleLabel?.font = config.font
    }
    
    private func applyContained(scheme: MDCContainerScheming)
    {
        applyContainedTheme(withScheme: scheme)
        setBackgroundColor(scheme.colorScheme.secondaryColor, for: .disabled)
        setTitleColor(scheme.colorScheme.onSecondaryColor, for: .disabled)
    }
    
    private func applyOutlined(scheme: MDCContainerScheming)
    {
        applyOutlinedTheme(withScheme: scheme)
        setBorderColor(scheme.colorScheme.secondaryColor, for: .normal)
        setTitleColor(scheme.colorScheme.onSecondaryColor, for: .disabled)
    }
    
    private func applyText(scheme: MDCContainerScheming)
    {
        applyTextTheme(withScheme: scheme)
    }

    enum SchemeType
    {
        case contained
        case outlined
        case text
    }
    
    // Event handling
    
    func setTouchUpInsideHandler(_ handler: @escaping (Button) -> Void)
    {
        touchUpInsideHandler = handler
        addTarget(self, action: #selector(onTouchUpInside(button:)), for: .touchUpInside)
    }
    
    @objc
    func onTouchUpInside(button: Button)
    {
        touchUpInsideHandler?(self)
    }
}

protocol ButtonAppearanceConfigProtocol
{
    var font: Font { get }
    var height: CGFloat { get }
    var scheme: MDCContainerScheme { get }
    var schemeType: Button.SchemeType { get }
}

extension Button
{
    struct ButtonAppearanceConfig: ButtonAppearanceConfigProtocol
    {
        let font: Font
        let height: CGFloat
        let schemeType: Button.SchemeType
        let schemeBuilder: (MDCContainerScheme) -> MDCContainerScheme
        var scheme: MDCContainerScheme { schemeBuilder(MDCContainerScheme()) }
    }
    
    static let largeContained = ButtonAppearanceConfig(font: .xolla_button, height: 60, schemeType: .contained)
    { scheme in
        
        scheme.colorScheme.primaryColor = .xsolla_magenta
        scheme.colorScheme.onPrimaryColor = .xsolla_white
        
        scheme.colorScheme.secondaryColor = .xsolla_inactiveMagenta
        scheme.colorScheme.onSecondaryColor = .xsolla_inactiveWhite
        
        let shapeScheme = MDCShapeScheme()
        
        shapeScheme.smallComponentShape = MDCShapeCategory(cornersWith: .rounded, andSize: Shape.largeCornerRadius)
        scheme.shapeScheme = shapeScheme
        
        return scheme
    }
    
    static let largeOutlined = ButtonAppearanceConfig(font: .xolla_button, height: 60, schemeType: .outlined)
    { scheme in
        
        scheme.colorScheme.primaryColor = .xsolla_lightSlateGrey
        scheme.colorScheme.secondaryColor = .xsolla_transparentSlateGrey
        scheme.colorScheme.onSecondaryColor = .xsolla_transparentSlateGrey
        
        let shapeScheme = MDCShapeScheme()
        
        shapeScheme.smallComponentShape = MDCShapeCategory(cornersWith: .rounded, andSize: Shape.largeCornerRadius)
        scheme.shapeScheme = shapeScheme
        
        return scheme
    }
    
    static let smallContained = ButtonAppearanceConfig(font: .xolla_label, height: 40, schemeType: .contained)
    { scheme in
        
        scheme.colorScheme.primaryColor = .xsolla_magenta
        scheme.colorScheme.onPrimaryColor = .xsolla_white
        
        scheme.colorScheme.secondaryColor = .xsolla_inactiveMagenta
        scheme.colorScheme.onSecondaryColor = .xsolla_inactiveWhite
        
        let shapeScheme = MDCShapeScheme()
        
        shapeScheme.smallComponentShape = MDCShapeCategory(cornersWith: .rounded, andSize: Shape.mediumCornerRadius)
        scheme.shapeScheme = shapeScheme
        
        return scheme
    }
    
    static let smallOutlined = ButtonAppearanceConfig(font: .xolla_label, height: 40, schemeType: .outlined)
    { scheme in
        
        scheme.colorScheme.primaryColor = .xsolla_lightSlateGrey
        scheme.colorScheme.secondaryColor = .xsolla_transparentSlateGrey
        scheme.colorScheme.onSecondaryColor = .xsolla_transparentSlateGrey
        
        let shapeScheme = MDCShapeScheme()
        
        shapeScheme.smallComponentShape = MDCShapeCategory(cornersWith: .rounded, andSize: Shape.mediumCornerRadius)
        scheme.shapeScheme = shapeScheme
        
        return scheme
    }
}
