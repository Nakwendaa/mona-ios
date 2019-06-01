//
//  LocalizedString+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension LocalizedString {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalizedString> {
        return NSFetchRequest<LocalizedString>(entityName: "LocalizedString")
    }

    @NSManaged public var language: Language
    @NSManaged public var localizedString: String
    @NSManaged public var localizableEntity: LocalizableEntity

}
