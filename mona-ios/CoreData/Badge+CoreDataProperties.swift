//
//  Badge+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-27.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension Badge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Badge> {
        return NSFetchRequest<Badge>(entityName: "Badge")
    }

    @NSManaged public var id: Int16
    @NSManaged public var targetValue: Int16
    @NSManaged public var collectedImageName: String?
    @NSManaged public var notCollectedImageName: String?

}
