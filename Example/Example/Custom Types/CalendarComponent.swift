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

enum CalendarComponent: String, CaseIterable
{
    case minute
    case hour
    case day
    case week
    case month
    case year
    
    var timeInterval: TimeInterval
    {
        switch self
        {
            case .minute: return 60
            case .hour: return 3600
            case .day: return 86400
            case .week: return 604800
            case .month: return 2678400
            case .year: return 31536000
        }
    }
    
    var component: NSCalendar.Unit
    {
        switch self
        {
            case .minute: return .minute
            case .hour: return .hour
            case .day: return .day
            case .week: return .weekOfMonth
            case .month: return .month
            case .year: return .year
        }
    }
    
    func localizedInterval(for value: Int) -> String
    {
        return Self.formatter.string(from: timeInterval * Double(value)) ?? ""
    }
    
    static let formatter: DateComponentsFormatter =
    {
        let dateComponentsFormatter = DateComponentsFormatter()
        
        dateComponentsFormatter.unitsStyle = .abbreviated
        dateComponentsFormatter.zeroFormattingBehavior = [.dropAll]
        dateComponentsFormatter.maximumUnitCount = 2
        dateComponentsFormatter.collapsesLargestUnit = false

        dateComponentsFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        
        return dateComponentsFormatter
    }()
}
