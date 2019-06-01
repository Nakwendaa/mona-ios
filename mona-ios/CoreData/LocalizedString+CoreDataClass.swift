//
//  LocalizedString+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-14.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(LocalizedString)
public class LocalizedString: NSManagedObject {

    @nonobjc public class func insert(language: Language, localized: String, to context: NSManagedObjectContext) -> LocalizedString {
        let localizedString : LocalizedString = CoreDataStack.getEntity(context: context)
        localizedString.language = language
        localizedString.localizedString = localized
        return localizedString
    }
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate?, context: NSManagedObjectContext) -> [LocalizedString] {
        do {
            let fetchRequest : NSFetchRequest<LocalizedString> = LocalizedString.fetchRequest()
            fetchRequest.predicate = predicate
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
        }
        catch {
            log.error("Fetch task failed: \(error)")
            return [LocalizedString]()
        }
    }
    
    @nonobjc public class func fetchRequest(language: Language, context: NSManagedObjectContext) -> LocalizedString? {
        return fetchRequest(predicate: NSPredicate(format: "language = %d", language.rawValue), context: context).first
    }
    
}
