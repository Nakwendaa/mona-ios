//
//  Subcategory+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension Subcategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subcategory> {
        return NSFetchRequest<Subcategory>(entityName: "Subcategory")
    }

    @NSManaged public var artworks: Set<Artwork>
    @NSManaged public var category: Category

}

// MARK: Generated accessors for artworks
extension Subcategory {

    @objc(addArtworksObject:)
    @NSManaged public func addToArtworks(_ value: Artwork)

    @objc(removeArtworksObject:)
    @NSManaged public func removeFromArtworks(_ value: Artwork)

    @objc(addArtworks:)
    @NSManaged public func addToArtworks(_ values: NSSet)

    @objc(removeArtworks:)
    @NSManaged public func removeFromArtworks(_ values: NSSet)

}
