//
//  NSDate+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-12.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation
import CoreData

extension NSDate {
    
    convenience init(dateString: String, dateFormat: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = dateFormat
        dateStringFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: date)
    }
    
    func toString (format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self as Date)
    }
    
}

extension NSManagedObject {
    
    @nonobjc public class func getCount(context: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
        do {
            let result = try context.count(for: fetchRequest)
            return result
        }
        catch {
            return 0
        }
    }
}
