//
//  Array+UIView.swift
//  XsollaPublisherAccount
//
//  Created by Dmitry Kovalev on 06/01/2020.
//  Copyright © 2020 Xsolla (USA), Inc. All rights reserved.
//

import UIKit

extension Array where Element: UIView
{
    func removeAllFromSuperview()
    {
        forEach { $0.removeFromSuperview() }
    }
}

extension Array
{
    func hasIndex(_ index: Int) -> Bool
    {
        (0..<count).contains(index)
    }
}
