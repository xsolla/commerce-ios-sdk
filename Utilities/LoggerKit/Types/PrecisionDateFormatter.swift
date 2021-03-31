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

import Foundation

class PrecisionDateFormatter
{
    let formatter = DateFormatter()
    let calendar = Calendar.current
    var formatType: LoggerTimeFormat = .timeMicros
    
    func string(from date: Date) -> String
    {
        switch formatType
        {
            case .full: return formattedString(date: date, format: formatType.dateFormat)
            case .fullMillis: return formattedString(date: date, format: formatType.dateFormat)
            case .fullMicros: return formattedStringWithMicroseconds(date: date, format: formatType.dateFormat)
            case .time: return formattedString(date: date, format: formatType.dateFormat)
            case .timeMillis: return formattedString(date: date, format: formatType.dateFormat)
            case .timeMicros: return formattedStringWithMicroseconds(date: date, format: formatType.dateFormat)
        }
    }
    
    func formattedStringWithMicroseconds(date: Date, format: String) -> String
    {
        formatter.dateFormat = format
        
        let components = calendar.dateComponents(Set([Calendar.Component.nanosecond]), from: date)

        let nanosecondsInMicrosecond = Double(1000)
        let microseconds = lrint(Double(components.nanosecond!) / nanosecondsInMicrosecond)

        let updatedDate = calendar.date(byAdding: .nanosecond, value: -(components.nanosecond!), to: date)!
        let dateTimeString = formatter.string(from: updatedDate)

        return String(format: "%@.%06ld", dateTimeString, microseconds)
    }
    
    func formattedString(date: Date, format: String) -> String
    {
        if formatter.dateFormat != format { formatter.dateFormat = format }
        return formatter.string(from: date)
    }
}

fileprivate extension LoggerTimeFormat
{
    var dateFormat: String
    {
        switch self
        {
            case .full: return "yyyy-MM-dd HH:mm:ss"
            case .fullMillis: return "yyyy-MM-dd HH:mm:ss.SSS"
            case .fullMicros: return "yyyy-MM-dd HH:mm:ss"
            case .time: return "HH:mm:ss"
            case .timeMillis: return "HH:mm:ss.SSS"
            case .timeMicros: return "HH:mm:ss"
        }
    }
}
