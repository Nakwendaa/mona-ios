//
//  Artist+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension Artist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist")
    }

    @NSManaged public var id: Int16
    @NSManaged public var isCollectiveName: Bool
    @NSManaged public var name: String?
    @NSManaged public var artworks: Set<Artwork>

}

// MARK: Generated accessors for artworks
extension Artist {

    @objc(addArtworksObject:)
    @NSManaged public func addToArtworks(_ value: Artwork)

    @objc(removeArtworksObject:)
    @NSManaged public func removeFromArtworks(_ value: Artwork)

    @objc(addArtworks:)
    @NSManaged public func addToArtworks(_ values: NSSet)

    @objc(removeArtworks:)
    @NSManaged public func removeFromArtworks(_ values: NSSet)

}
