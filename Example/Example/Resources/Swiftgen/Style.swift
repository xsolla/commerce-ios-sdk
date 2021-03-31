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

// swiftlint:disable line_length

import UIKit

struct Style
{
    let font: UIFont
    let lineHeight: CGFloat
    let kern: CGFloat
    let align: NSTextAlignment
    let verticalAlign: VerticalAlignment
    let paragraphSpacing: CGFloat?
    let paragraphSpacingBefore: CGFloat?
    let firstLineHeadIndent: CGFloat?
    let lineSpacing: CGFloat?

    init(font: UIFont,
         lineHeight: CGFloat,
         kern: CGFloat,
         align: NSTextAlignment,
         verticalAlign: VerticalAlignment = .center,
         paragraphSpacing: CGFloat? = nil,
         paragraphSpacingBefore: CGFloat? = nil,
         firstLineHeadIndent: CGFloat? = nil,
         lineSpacing: CGFloat? = nil)
    {
        self.font = font
        self.lineHeight = lineHeight
        self.kern = kern
        self.align = align
        self.verticalAlign = verticalAlign
        self.paragraphSpacing = paragraphSpacing
        self.paragraphSpacingBefore = paragraphSpacingBefore
        self.firstLineHeadIndent = firstLineHeadIndent
        self.lineSpacing = lineSpacing
    }
}

extension Style
{
    func copy(font: UIFont? = nil,
              lineHeight: CGFloat? = nil,
              kern: CGFloat? = nil,
              align: NSTextAlignment? = nil,
              verticalAlign: VerticalAlignment? = nil,
              paragraphSpacing: CGFloat? = nil,
              paragraphSpacingBefore: CGFloat? = nil,
              firstLineHeadIndent: CGFloat? = nil,
              lineSpacing: CGFloat? = nil) -> Style
    {
        return Style(font: font ?? self.font,
                           lineHeight: lineHeight ?? self.lineHeight,
                           kern: kern ?? self.kern,
                           align: align ?? self.align,
                           verticalAlign: verticalAlign ?? self.verticalAlign,
                           paragraphSpacing: paragraphSpacing ?? self.paragraphSpacing,
                           paragraphSpacingBefore: paragraphSpacingBefore ?? self.paragraphSpacingBefore,
                           firstLineHeadIndent: firstLineHeadIndent ?? self.firstLineHeadIndent,
                           lineSpacing: lineSpacing ?? self.lineSpacing)
    }
}

extension Style
{
    func attributes(withColor color: UIColor? = nil) -> Attributes
    {
        var attributes: Attributes =
        [
            .kern: self.kern,
            .paragraphStyle: self.paragraphStyle()
        ]

        attributes[.font] = font
        
        if let color = color { attributes[.foregroundColor] = color }

        return attributes
    }
    
    private func paragraphStyle() -> NSMutableParagraphStyle
    {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = self.align
        
        if let paragraphSpacing = self.paragraphSpacing { paragraphStyle.paragraphSpacing = paragraphSpacing }
        
        if let paragraphSpacingBefore = self.paragraphSpacingBefore { paragraphStyle.paragraphSpacingBefore = paragraphSpacingBefore }
        
        if let firstLineHeadIndent = self.firstLineHeadIndent { paragraphStyle.firstLineHeadIndent = firstLineHeadIndent }
        
        if let lineSpacing = self.lineSpacing { paragraphStyle.lineSpacing = lineSpacing }
        
        if lineHeight > 0
        {
            switch verticalAlign
            {
                case .top: do
                {
                    paragraphStyle.lineSpacing = lineHeight - font.lineHeight
                }

                case .center: do
                {
                    let lineSpacing: CGFloat = (lineHeight - font.lineHeight) / 2
                    let lineHeightMultiple = (lineHeight-lineSpacing) / font.lineHeight
                    paragraphStyle.lineSpacing = lineSpacing
                    paragraphStyle.lineHeightMultiple = lineHeightMultiple
                }

                case .bottom: do
                {
                    paragraphStyle.lineHeightMultiple = lineHeight / font.lineHeight
                }
            }
        }
        
        return paragraphStyle
    }

    func lineHeight(_ lineHeight: CGFloat, align: VerticalAlignment = .center) -> Self
    {
        return copy(lineHeight: lineHeight, verticalAlign: align)
    }

    func align(_ align: NSTextAlignment) -> Self
    {
        return copy(align: align)
    }
    
    func paragraphSpacing(_ paragraphSpacing: CGFloat) -> Self
    {
        return copy(paragraphSpacing: paragraphSpacing)
    }
    
    func paragraphSpacingBefore(_ paragraphSpacingBefore: CGFloat) -> Self
    {
        return copy(paragraphSpacingBefore: paragraphSpacingBefore)
    }
    
    func firstLineHeadIndent(_ firstLineHeadIndent: CGFloat) -> Self
    {
        return copy(firstLineHeadIndent: firstLineHeadIndent)
    }
    
    func lineSpacing(_ lineSpacing: CGFloat) -> Self
    {
        return copy(lineSpacing: lineSpacing)
    }
    
    func paragraphParams(paragraphSpacing: CGFloat? = nil,
                         paragraphSpacingBefore: CGFloat? = nil,
                         firstLineHeadIndent: CGFloat? = nil,
                         lineSpacing: CGFloat? = nil) -> Self
    {
        return copy(paragraphSpacing: paragraphSpacing ?? self.paragraphSpacing,
                    paragraphSpacingBefore: paragraphSpacingBefore ?? self.paragraphSpacingBefore,
                    firstLineHeadIndent: firstLineHeadIndent ?? self.firstLineHeadIndent,
                    lineSpacing: lineSpacing ?? self.lineSpacing)
    }
}

extension Style
{
    enum VerticalAlignment
    {
        case top
        case center
        case bottom
    }
}

extension Style
{
    static let button = Style(font: SystemFont.bold.size(18), lineHeight: 24, kern: 0, align: .natural)
    static let label = Style(font: SystemFont.bold.size(14), lineHeight: 16, kern: 0, align: .natural)
    static let heading1 = Style(font: SystemFont.bold.size(20), lineHeight: 24, kern: 0.15, align: .natural)
    static let heading2 = Style(font: SystemFont.bold.size(18), lineHeight: 24, kern: 0, align: .natural)
    static let description = Style(font: SystemFont.regular.size(16), lineHeight: 24, kern: 0, align: .natural)
    static let discount = Style(font: SystemFont.regular.size(14), lineHeight: 20, kern: 0, align: .natural)
    static let link = Style(font: SystemFont.regular.size(14), lineHeight: 18, kern: 0, align: .natural)
    static let caption = Style(font: SystemFont.regular.size(12), lineHeight: 16, kern: 0, align: .natural)
    static let notification = Style(font: SystemFont.regular.size(12), lineHeight: 16, kern: 0, align: .natural)
}

extension Style
{
    typealias Roboto = Font.Roboto
}

extension NSAttributedString
{
    convenience init(string: String, style: Style, color: UIColor? = nil, attributes attrs: Attributes? = nil)
    {
        var attrs = attrs

        var attributes = style.attributes(withColor: color)

        if let customParagraphStyle = attrs?[.paragraphStyle] as? NSParagraphStyle
        {
            attrs?.removeValue(forKey: .paragraphStyle)
            if let paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle
            {
                paragraphStyle.setParagraphStyle(customParagraphStyle)
            }
            else
            {
                attributes[.paragraphStyle] = customParagraphStyle
            }
        }

        if let attrs = attrs { attributes.merge(attrs) { $1 } }

        self.init(string: string, attributes: attributes)
    }
}

extension String
{
    func attributed(_ style: Style, color: UIColor?, attributes: Attributes? = nil) -> NSAttributedString
    {
        NSAttributedString(string: self, style: style, color: color, attributes: attributes)
    }
    
    func attributed(_ attributes: Attributes?) -> NSAttributedString
    {
        NSAttributedString(string: self, attributes: attributes)
    }

    func attributedMutable(_ style: Style, color: UIColor?, attributes: Attributes? = nil) -> NSMutableAttributedString
    {
        NSMutableAttributedString(string: self, style: style, color: color, attributes: attributes)
    }
    
    func attributedMutable(_ attributes: Attributes?) -> NSMutableAttributedString
    {
        NSMutableAttributedString(string: self, attributes: attributes)
    }
}
