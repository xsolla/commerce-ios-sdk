// XSOLLA_SDK_LICENCE_HEADER_PLACEHOLDER

import Foundation
import XsollaSDKUtilities

extension LogCategory
{
    public static let loginKit = Self.init(title: "LoginKit")
    public static let inventoryKit = Self.init(title: "InventoryKit")
    public static let paymentsKit = Self.init(title: "PaymentsKit")
    public static let storeKit = Self.init(title: "StoreKit")
        
    public static let all: [LogCategory] =
    [
        .common,
        .initialization,
        .deinitialization,
        .networking,
        .navigation,
        .ui,
        .debug,
        .loginKit,
        .inventoryKit,
        .paymentsKit,
        .storeKit
    ]
    
    public static func all(excluding: [LogCategory]) -> [LogCategory]
    {
        all.filter { category in (excluding.filter { $0.description == category.description }).isEmpty }
    }
}
