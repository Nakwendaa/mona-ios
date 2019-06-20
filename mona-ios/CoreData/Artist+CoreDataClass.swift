//
//  Artist+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-10.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Artist)
final public class Artist: NSManagedObject {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate?, context: NSManagedObjectContext) -> [Artist] {
        do {
            let fetchRequest : NSFetchRequest<Artist> = Artist.fetchRequest()
            fetchRequest.predicate = predicate
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
        }
        catch {
            log.error("Fetch task failed: \(error)")
            return [Artist]()
        }
    }
    
    @nonobjc public class func fetchRequest(id: Int16, context: NSManagedObjectContext) -> Artist? {
        return fetchRequest(predicate: NSPredicate(format: "id = %d", id), context: context).first
    }
    
    @nonobjc public class func fetchRequest(name: String, context: NSManagedObjectContext) -> Artist? {
        return fetchRequest(predicate: NSPredicate(format: "name = %@", name), context: context).first
    }
}
