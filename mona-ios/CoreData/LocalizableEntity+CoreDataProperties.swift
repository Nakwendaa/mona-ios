//
//  LocalizableEntity+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension LocalizableEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalizableEntity> {
        return NSFetchRequest<LocalizableEntity>(entityName: "LocalizableEntity")
    }

    @NSManaged public var localizedNames: Set<LocalizedString>

}

// MARK: Generated accessors for localizedNames
extension LocalizableEntity {

    @objc(addLocalizedNamesObject:)
    @NSManaged public func addToLocalizedNames(_ value: LocalizedString)

    @objc(removeLocalizedNamesObject:)
    @NSManaged public func removeFromLocalizedNames(_ value: LocalizedString)

    @objc(addLocalizedNames:)
    @NSManaged public func addToLocalizedNames(_ values: NSSet)

    @objc(removeLocalizedNames:)
    @NSManaged public func removeFromLocalizedNames(_ values: NSSet)

}
