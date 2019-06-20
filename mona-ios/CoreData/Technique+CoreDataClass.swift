//
//  Technique+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Technique)
final public class Technique: LocalizableEntity {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate?, context: NSManagedObjectContext) -> [Technique] {
        do {
            let fetchRequest : NSFetchRequest<Technique> = Technique.fetchRequest()
            fetchRequest.predicate = predicate
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
        }
        catch {
            log.error("Fetch task failed: \(error)")
            return [Technique]()
        }
    }
    
    @nonobjc public class func fetchRequest(name: String, context: NSManagedObjectContext) -> Technique? {
        return fetchRequest(predicate: NSPredicate(format: "%@ IN localizedNames.localizedString", name), context: context).first
    }
    
}
