//
//  Artwork+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-23.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension Artwork {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artwork> {
        return NSFetchRequest<Artwork>(entityName: "Artwork")
    }

    @NSManaged public var comment: String?
    @NSManaged public var commentSent: Bool
    @NSManaged public var date: Date?
    @NSManaged public var dimensions: String?
    @NSManaged public var id: Int16
    @NSManaged public var isCollected: Bool
    @NSManaged public var isTargeted: Bool
    @NSManaged public var photoSent: Bool
    @NSManaged public var rating: Int16
    @NSManaged public var ratingSent: Bool
    @NSManaged public var title: String?
    @NSManaged public var address: Address
    @NSManaged public var artists: Set<Artist>
    @NSManaged public var category: Category
    @NSManaged public var district: District
    @NSManaged public var materials: Set<Material>
    @NSManaged public var photos: NSOrderedSet?
    @NSManaged public var subcategory: Subcategory?
    @NSManaged public var techniques: Set<Technique>

}

// MARK: Generated accessors for artists
extension Artwork {

    @objc(addArtistsObject:)
    @NSManaged public func addToArtists(_ value: Artist)

    @objc(removeArtistsObject:)
    @NSManaged public func removeFromArtists(_ value: Artist)

    @objc(addArtists:)
    @NSManaged public func addToArtists(_ values: NSSet)

    @objc(removeArtists:)
    @NSManaged public func removeFromArtists(_ values: NSSet)

}

// MARK: Generated accessors for materials
extension Artwork {

    @objc(addMaterialsObject:)
    @NSManaged public func addToMaterials(_ value: Material)

    @objc(removeMaterialsObject:)
    @NSManaged public func removeFromMaterials(_ value: Material)

    @objc(addMaterials:)
    @NSManaged public func addToMaterials(_ values: NSSet)

    @objc(removeMaterials:)
    @NSManaged public func removeFromMaterials(_ values: NSSet)

}

// MARK: Generated accessors for photos
extension Artwork {

    @objc(insertObject:inPhotosAtIndex:)
    @NSManaged public func insertIntoPhotos(_ value: Photo, at idx: Int)

    @objc(removeObjectFromPhotosAtIndex:)
    @NSManaged public func removeFromPhotos(at idx: Int)

    @objc(insertPhotos:atIndexes:)
    @NSManaged public func insertIntoPhotos(_ values: [Photo], at indexes: NSIndexSet)

    @objc(removePhotosAtIndexes:)
    @NSManaged public func removeFromPhotos(at indexes: NSIndexSet)

    @objc(replaceObjectInPhotosAtIndex:withObject:)
    @NSManaged public func replacePhotos(at idx: Int, with value: Photo)

    @objc(replacePhotosAtIndexes:withPhotos:)
    @NSManaged public func replacePhotos(at indexes: NSIndexSet, with values: [Photo])

    /* BUG with auto generated methods
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
    
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)
     */

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSOrderedSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSOrderedSet)

}

// MARK: Generated accessors for techniques
extension Artwork {

    @objc(addTechniquesObject:)
    @NSManaged public func addToTechniques(_ value: Technique)

    @objc(removeTechniquesObject:)
    @NSManaged public func removeFromTechniques(_ value: Technique)

    @objc(addTechniques:)
    @NSManaged public func addToTechniques(_ values: NSSet)

    @objc(removeTechniques:)
    @NSManaged public func removeFromTechniques(_ values: NSSet)

}
