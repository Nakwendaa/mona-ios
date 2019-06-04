//
//  Badge+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-03.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension Badge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Badge> {
        return NSFetchRequest<Badge>(entityName: "Badge")
    }

    @NSManaged public var collectedImageName: String
    @NSManaged public var id: Int16
    @NSManaged public var notCollectedImageName: String
    @NSManaged public var targetValue: Int16
    @NSManaged public var currentValue: Int16
    @NSManaged public var comments: Set<LocalizedString>?

}

// MARK: Generated accessors for comments
extension Badge {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: LocalizedString)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: LocalizedString)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
