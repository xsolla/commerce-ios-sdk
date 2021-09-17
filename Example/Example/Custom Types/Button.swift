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

// swiftlint:disable nesting

class Button: UIButton
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
    }

    func setEnabled(_ enabled: Bool, animated: Bool)
    {
        isEnabled = enabled
    }

    func setupAppearance(config: ButtonAppearanceConfigProtocol)
    {
        heightConstraint.constant = config.height

        stateSchemes = config.stateSchemes

        titleLabel?.font = config.font

        layer.masksToBounds = true
        contentEdgeInsets = config.insets

        resetAppearance()
    }

    func setTitle(_ text: String?,
                  attributes: Attributes = Style.button.attributes(withColor: .xsolla_white),
                  for state: UIControl.State = .normal)
    {
        setAttributedTitle(text?.attributed(attributes), for: state)
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

    // MARK: - Schemes

    private var stateSchemes: StateSchemes = [:]

    func setCornerRadius(_ radius: CGFloat, for state: UIControl.State, redraw: Bool = true)
    {
        var scheme = stateSchemes[state] ?? Scheme()
        scheme.cornerRadius = radius
        stateSchemes[state] = scheme

        if redraw { resetAppearance() }
    }

    func setBorderWidth(_ width: CGFloat, for state: UIControl.State, redraw: Bool = true)
    {
        var scheme = stateSchemes[state] ?? Scheme()
        scheme.borderWidth = width
        stateSchemes[state] = scheme

        if redraw { resetAppearance() }
    }

    func setBorderColor(_ color: UIColor, for state: UIControl.State, redraw: Bool = true)
    {
        var scheme = stateSchemes[state] ?? Scheme()
        scheme.borderColor = color
        stateSchemes[state] = scheme

        if redraw { resetAppearance() }
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State, redraw: Bool = true)
    {
        var scheme = stateSchemes[state] ?? Scheme()
        scheme.backgroundColor = color
        stateSchemes[state] = scheme

        if redraw { resetAppearance() }
    }

    private var statesToRedraw: [UIControl.State] = [.normal, .disabled, .selected, .focused, .highlighted]

    private func resetAppearance()
    {
        let normalScheme = stateSchemes[.normal] ?? Scheme()

        for state in statesToRedraw
        {
            let backgroundColor = stateSchemes[state]?.backgroundColor ?? normalScheme.backgroundColor ?? .clear
            let foregroundColor = stateSchemes[state]?.foregroundColor ?? normalScheme.foregroundColor ?? .systemBlue
            let borderColor = stateSchemes[state]?.borderColor ?? normalScheme.borderColor ?? .clear
            let cornerRadius = stateSchemes[state]?.cornerRadius ?? normalScheme.cornerRadius ?? 0
            let borderWidth = stateSchemes[state]?.borderWidth ?? normalScheme.borderWidth ?? 0

            setTitleColor(foregroundColor, for: state)

            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
            guard let context = UIGraphicsGetCurrentContext() else { continue }

            if borderWidth > 0 { layer.borderWidth = 0 }

            context.addPath(UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth, dy: borderWidth),
                                         cornerRadius: cornerRadius).cgPath)

            context.setStrokeColor(borderColor.cgColor)
            context.setFillColor(backgroundColor.cgColor)
            context.setLineWidth(borderWidth)

            context.closePath()
            context.drawPath(using: .fillStroke)

            let insets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            let resizableImage = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)

            UIGraphicsEndImageContext()

            setBackgroundImage(resizableImage, for: state)
        }
    }

    var lastSize: CGSize = .zero

    override func layoutSubviews()
    {
        super.layoutSubviews()

        if bounds.size != lastSize { resetAppearance() }
        lastSize = bounds.size
    }
}

extension UIControl.State: Hashable
{
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(Int(rawValue))
    }
}

protocol ButtonAppearanceConfigProtocol
{
    var font: Font { get }
    var height: CGFloat { get }
    var insets: UIEdgeInsets { get }
    var stateSchemes: Button.StateSchemes { get }
}

extension Button
{
    typealias StateSchemes = [UIControl.State: Scheme]

    struct Scheme
    {
        var backgroundColor: UIColor? = .clear
        var foregroundColor: UIColor? = .systemBlue
        var borderColor: UIColor? = .clear
        var borderWidth: CGFloat?
        var cornerRadius: CGFloat?
    }

    struct ButtonAppearanceConfig: ButtonAppearanceConfigProtocol
    {
        let font: Font
        let height: CGFloat
        var insets: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
        let schemeBuilder: () -> Button.StateSchemes
        var stateSchemes: Button.StateSchemes { schemeBuilder() }

        typealias Scheme = Button.Scheme
    }
    
    static let largeContained = ButtonAppearanceConfig(font: .xolla_button, height: 56)
    {
        var schemes = StateSchemes()

        schemes[.normal] = Scheme(backgroundColor: .xsolla_magenta,
                                  foregroundColor: .xsolla_white,
                                  cornerRadius: Shape.largeCornerRadius)
        
        schemes[.disabled] = Scheme(backgroundColor: .xsolla_inactiveMagenta, foregroundColor: .xsolla_inactiveWhite)

        return schemes
    }
    
    static let largeOutlined = ButtonAppearanceConfig(font: .xolla_button, height: 60)
    {
        var schemes = StateSchemes()

        schemes[.normal] = Scheme(foregroundColor: .xsolla_white,
                                  borderColor: .xsolla_inactiveWhite,
                                  borderWidth: 1,
                                  cornerRadius: Shape.largeCornerRadius)

        schemes[.disabled] = Scheme(foregroundColor: .xsolla_inactiveWhite,
                                    borderColor: UIColor.xsolla_inactiveWhite.withAlphaComponent(0.5))
        
        schemes[.highlighted] = Scheme(borderColor: .xsolla_white)

        return schemes
    }
    
    static let smallContained = ButtonAppearanceConfig(font: .xolla_label, height: 40)
    {
        var schemes = StateSchemes()

        schemes[.normal] = Scheme(backgroundColor: .xsolla_magenta,
                                  foregroundColor: .xsolla_white,
                                  cornerRadius: Shape.mediumCornerRadius)
        
        schemes[.disabled] = Scheme(backgroundColor: .xsolla_inactiveMagenta, foregroundColor: .xsolla_inactiveWhite)

        return schemes
    }

    static let smallOutlined = ButtonAppearanceConfig(font: .xolla_label, height: 40)
    {
        var schemes = StateSchemes()

        schemes[.normal] = Scheme(foregroundColor: .xsolla_white,
                                  borderColor: .xsolla_inactiveWhite,
                                  borderWidth: 1,
                                  cornerRadius: Shape.mediumCornerRadius)

        schemes[.disabled] = Scheme(foregroundColor: .xsolla_inactiveWhite,
                                    borderColor: UIColor.xsolla_inactiveWhite.withAlphaComponent(0.5))
        
        schemes[.highlighted] = Scheme(borderColor: .xsolla_white)

        return schemes
    }

    static let smallOutlinedDestructive = ButtonAppearanceConfig(font: .xolla_label, height: 40)
    {
        var schemes = StateSchemes()

        schemes[.normal] = Scheme(borderColor: .xsolla_inactiveWhite,
                                  borderWidth: 1,
                                  cornerRadius: Shape.mediumCornerRadius)

        schemes[.disabled] = Scheme(borderColor: UIColor.xsolla_inactiveWhite.withAlphaComponent(0.5))
        schemes[.highlighted] = Scheme(borderColor: .xsolla_white)

        return schemes
    }
}
