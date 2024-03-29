// XSOLLA_SDK_LICENCE_HEADER_PLACEHOLDER

import Foundation
import XsollaSDKUtilities

class LoggerKitDefaultFilter: LoggerKitBaseFilter
{
    var excludingLevels: [LogLevel] = []
    var excludingCategories: [LogCategory] = []
    var excludingDomains: [LogDomain] = []
    
    // You can use multiple search words separated by comma
    // No spaces are allowed in search strings! Ex.: "one,two,three"
    var fileSearchIncludeString: String = ""
    var fileSearchExcludeString: String = ""
    var methodSearchIncludeString: String = ""
    var methodSearchExcludeString: String = ""
    
    override func shouldLog(level: LogLevelProtocol) -> Bool
    {
        guard let level = level as? LogLevel else { return false }
        
        return LogLevel.all(excluding: excludingLevels).contains(level)
    }
    
    override func shouldLog(category: LogCategoryProtocol) -> Bool
    {
        guard let category = category as? LogCategory else { return false }
        
        return LogCategory.all(excluding: excludingCategories).contains(category)
    }
    
    override func shouldLog(domain: LogDomainProtocol) -> Bool
    {
        guard let domain = domain as? LogDomain else { return false }
        
        return LogDomain.all(excluding: excludingDomains).contains(domain)
    }
    
    override func shouldLog(filePath: StaticString) -> Bool
    {
        if !fileSearchIncludeString.isEmpty
        {
            return fileSearchIncludeString
                .lowercased()
                .components(separatedBy: ",")
                .contains(where: filePath.description.lowercased().contains)
        }
        
        if !fileSearchExcludeString.isEmpty
        {
            return !fileSearchExcludeString
                .lowercased()
                .components(separatedBy: ",")
                .contains(where: filePath.description.lowercased().contains)
        }
        
        return true
    }
    
    override func shouldLog(methodName: StaticString) -> Bool
    {
        if !methodSearchIncludeString.isEmpty
        {
            return methodSearchIncludeString
                .lowercased()
                .components(separatedBy: ",")
                .contains(where: methodName.description.lowercased().contains)
        }
        
        if !methodSearchExcludeString.isEmpty
        {
            return !methodSearchExcludeString
                .lowercased()
                .components(separatedBy: ",")
                .contains(where: methodName.description.lowercased().contains)
        }
        
        return true
    }
}

fileprivate extension Array where Element: CustomStringConvertible
{
    func contains(_ element: Element) -> Bool
    {
        (filter { $0.description == element.description }).count > 0
    }
}
