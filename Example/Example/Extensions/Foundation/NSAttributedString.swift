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

typealias Attributes = [NSAttributedString.Key: Any]

extension NSAttributedString
{
    enum ImageLocation
    {
        case left
        case right
    }
    
    func appendImage(_ image: UIImage, to location: ImageLocation) -> NSMutableAttributedString
    {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageAttachmentString = NSAttributedString(attachment: imageAttachment)
        
        let mutableAttributedString = NSMutableAttributedString()
        if location == .left
        {
            mutableAttributedString.append(imageAttachmentString)
            mutableAttributedString.append(self)
        } else
        {
            mutableAttributedString.append(self)
            mutableAttributedString.append(imageAttachmentString)
        }
        return mutableAttributedString
    }
    
    func appendImageCentered(_ image: UIImage, to location: ImageLocation, font: Font) -> NSMutableAttributedString
    {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0,
                                        y: (font.capHeight - image.size.height).rounded() / 2,
                                        width: image.size.width,
                                        height: image.size.height)
        imageAttachment.image = image
        
        let imageAttachmentString = NSAttributedString(attachment: imageAttachment)
        
        let mutableAttributedString = NSMutableAttributedString()
        if location == .left
        {
            mutableAttributedString.append(imageAttachmentString)
            mutableAttributedString.append(self)
        } else
        {
            mutableAttributedString.append(self)
            mutableAttributedString.append(imageAttachmentString)
        }
        return mutableAttributedString
    }

    func lineHeight(withConstrainedWidth width: CGFloat) -> CGFloat
    {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func lineWidth(withConstrainedHeight height: CGFloat) -> CGFloat
    {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func withAttributedSubstrings(_ attributedSubstrings: [NSAttributedString],
                                  replacingSymbol: String = "%s") -> NSMutableAttributedString
    {
        let newAttributedString = NSMutableAttributedString(attributedString: self)
        
        var range = NSString(string: newAttributedString.string).range(of: replacingSymbol)
        var substringIndex = 0
        
        while range.length > 0 && substringIndex < attributedSubstrings.count
        {
            newAttributedString.replaceCharacters(in: range, with: attributedSubstrings[substringIndex])
            range = NSString(string: newAttributedString.string).range(of: replacingSymbol)
            substringIndex += 1
        }
        
        return newAttributedString
    }
    
    func aligned(_ align: NSTextAlignment) -> NSAttributedString
    {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
                
        mutableAttributedString.addAttribute(.paragraphStyle,
                                             value: paragraphStyle,
                                             range: NSRange(location: 0, length: mutableAttributedString.length))
        
        return NSAttributedString(attributedString: mutableAttributedString)
    }
    
    var striked: NSAttributedString
    {
        let attributedString = NSMutableAttributedString(attributedString: self)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSRange(location: 0, length: attributedString.length))
        
        return NSAttributedString(attributedString: attributedString)
    }
    
    var underlined: NSAttributedString
    {
        let attributedString = NSMutableAttributedString(attributedString: self)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSRange(location: 0, length: attributedString.length))
        
        return NSAttributedString(attributedString: attributedString)
    }
}
