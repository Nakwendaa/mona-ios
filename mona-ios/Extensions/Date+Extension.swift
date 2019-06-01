//
//  Date+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-14.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

extension Date {
    
    init(dateString: String, dateFormat: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = dateFormat
        dateStringFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self = dateStringFormatter.date(from: dateString)!
    }
    
    func toString (format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
    
}
