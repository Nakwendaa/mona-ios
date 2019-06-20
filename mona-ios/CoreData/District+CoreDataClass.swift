//
//  District+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-10.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(District)
final public class District: NSManagedObject {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate?, context: NSManagedObjectContext) -> [District] {
        do {
            let fetchRequest : NSFetchRequest<District> = District.fetchRequest()
            fetchRequest.predicate = predicate
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
        }
        catch {
            log.error("Fetch task failed: \(error)")
            return [District]()
        }
    }
    
    @nonobjc public class func fetchRequest(name: String, context: NSManagedObjectContext) -> District? {
        return fetchRequest(predicate: NSPredicate(format: "name = %@", name), context: context).first
    }
    
}
