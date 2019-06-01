//
//  Technique+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension Technique {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Technique> {
        return NSFetchRequest<Technique>(entityName: "Technique")
    }

    @NSManaged public var artworks: Set<Artwork>

}

// MARK: Generated accessors for artworks
extension Technique {

    @objc(addArtworksObject:)
    @NSManaged public func addToArtworks(_ value: Artwork)

    @objc(removeArtworksObject:)
    @NSManaged public func removeFromArtworks(_ value: Artwork)

    @objc(addArtworks:)
    @NSManaged public func addToArtworks(_ values: NSSet)

    @objc(removeArtworks:)
    @NSManaged public func removeFromArtworks(_ values: NSSet)

}
