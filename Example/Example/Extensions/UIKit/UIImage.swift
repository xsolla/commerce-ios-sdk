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

extension UIImage
{
    // colorize image with given tint color
    func tint(tintColor: UIColor, preserveLuminosity: Bool = false) -> UIImage
    {
        let modifiedImage = modifiedImage
        { context, rect in
            
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            
            if let cgImage = self.cgImage
            {
                context.draw(cgImage, in: rect)
                
                // tint image (loosing alpha)
                context.setBlendMode(preserveLuminosity ? .color : .normal)
                tintColor.setFill()
                context.fill(rect)
                
                // mask by alpha values of original image
                context.setBlendMode(.destinationIn)
                context.draw(cgImage, in: rect)
            }
        }

        return modifiedImage ?? self
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> Void) -> UIImage?
    {
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage
{
    var template: UIImage
    {
        return self.withRenderingMode(.alwaysTemplate)
    }
}

extension ImageAsset
{
    var template: UIImage
    {
        return image.template
    }
    
    func tinted(_ color: UIColor) -> UIImage
    {
        return image.tint(tintColor: color)
    }
}
