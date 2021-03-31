// XSOLLA_SDK_LICENCE_HEADER_PLACEHOLDER

import Foundation
import XsollaSDKUtilities

extension LogDomain
{
    // This is how you add the custom domains to suit your needs
    
    public static let example = Self(title: "Example App")

    public static let all: [LogDomain] =
    [
        .common,
        .example
    ]
    
    public static func all(excluding: [LogDomain]) -> [LogDomain]
    {
        all.filter { domain in (excluding.filter { $0.description == domain.description }).isEmpty }
    }
}
