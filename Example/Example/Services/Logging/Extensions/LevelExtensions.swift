// XSOLLA_SDK_LICENCE_HEADER_PLACEHOLDER

import Foundation
import XsollaSDKUtilities

extension LogLevel
{
    public static let all: [LogLevel] = [.verbose, .event, .debug, .info, .warning, .error, .notice]
    
    public static func all(excluding: [LogLevel]) -> [LogLevel]
    {
        all.filter { level in (excluding.filter { $0.description == level.description }).isEmpty }
    }
}
