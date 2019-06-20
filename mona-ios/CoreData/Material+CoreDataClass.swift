//
//  Material+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Material)
final public class Material: LocalizableEntity {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate?, context: NSManagedObjectContext) -> [Material] {
        do {
            let fetchRequest : NSFetchRequest<Material> = Material.fetchRequest()
            fetchRequest.predicate = predicate
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
        }
        catch {
            log.error("Fetch task failed: \(error)")
            return [Material]()
        }
    }
    
    @nonobjc public class func fetchRequest(name: String, context: NSManagedObjectContext) -> Material? {
        return fetchRequest(predicate: NSPredicate(format: "%@ IN localizedNames.localizedString", name), context: context).first
    }

}
