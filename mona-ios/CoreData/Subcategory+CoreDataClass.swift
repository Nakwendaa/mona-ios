//
//  Subcategory+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Subcategory)
public class Subcategory: LocalizableEntity {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate?, context: NSManagedObjectContext) -> [Subcategory] {
        do {
            let fetchRequest : NSFetchRequest<Subcategory> = Subcategory.fetchRequest()
            fetchRequest.predicate = predicate
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
        }
        catch {
            log.error("Fetch task failed: \(error)")
            return [Subcategory]()
        }
    }
    
    // Si le name est dans les localizedName de la catégorie
    @nonobjc public class func fetchRequest(name: String, context: NSManagedObjectContext) -> Subcategory? {
        return fetchRequest(predicate: NSPredicate(format: "%@ IN localizedNames.localizedString", name), context: context).first
    }
    
}
