// XSOLLA_SDK_LICENCE_HEADER_PLACEHOLDER

import Foundation
import XsollaSDKUtilities

/// Global var for utilities logging service
let logger: DefaultLoggerKit =
{
    let levels = LogLevel.all
    
    var configuration = LoggerKitConfiguration(filter: LoggerKitFilter())
    
//    configuration.logContext = true
//    configuration.logTimestamp = false
    
    let configurator = LoggerKitConfigurator(configuration: configuration)
    let service = DefaultLoggerKit(configurator: configurator)
    
    return service
}()
