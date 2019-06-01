//
//  Photo+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-27.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var localIdentifier: String
    @NSManaged public var artwork: Artwork?

}
