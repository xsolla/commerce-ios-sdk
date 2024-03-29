//
//  Optional+String.swift
//  XsollaPublisherAccount
//
//  Created by Dmitry Kovalev on 14/11/2019.
//  Copyright © 2019 Xsolla (USA), Inc. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String
{
    var nilIfEmpty: String?
    {
        guard let strongSelf = self else { return nil }
        return strongSelf.isEmpty ? nil : strongSelf
    }
    
    var notEmpty: Bool
    {
        if let strongSelf = self, !strongSelf.isEmpty { return true }
        
        return false
    }
    
    var isEmpty: Bool
    {
        guard let strongSelf = self else { return true }

        return strongSelf.isEmpty
    }
    
    func ifEmpty(then value: String) -> String
    {
        isEmpty ? value : self!
    }
}
