//
//  Category+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Category)
final public class Category: LocalizableEntity {

    @nonobjc public class func fetchRequest(predicate: NSPredicate?, context: NSManagedObjectContext) -> [Category] {
        do {
            let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
            fetchRequest.predicate = predicate
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
        }
        catch {
            log.error("Fetch task failed: \(error)")
            return [Category]()
        }
    }
    
    @nonobjc public class func fetchRequest(name: String, context: NSManagedObjectContext) -> Category? {
        return fetchRequest(predicate: NSPredicate(format: "%@ IN localizedNames.localizedString", name), context: context).first
    }
}
