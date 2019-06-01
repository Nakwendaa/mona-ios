//
//  District+CoreDataProperties.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData


extension District {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<District> {
        return NSFetchRequest<District>(entityName: "District")
    }

    @NSManaged public var name: String
    @NSManaged public var addresses: Set<Address>
    @NSManaged public var artworks: Set<Artwork>

}

// MARK: Generated accessors for addresses
extension District {

    @objc(addAddressesObject:)
    @NSManaged public func addToAddresses(_ value: Address)

    @objc(removeAddressesObject:)
    @NSManaged public func removeFromAddresses(_ value: Address)

    @objc(addAddresses:)
    @NSManaged public func addToAddresses(_ values: NSSet)

    @objc(removeAddresses:)
    @NSManaged public func removeFromAddresses(_ values: NSSet)

}

// MARK: Generated accessors for artworks
extension District {

    @objc(addArtworksObject:)
    @NSManaged public func addToArtworks(_ value: Artwork)

    @objc(removeArtworksObject:)
    @NSManaged public func removeFromArtworks(_ value: Artwork)

    @objc(addArtworks:)
    @NSManaged public func addToArtworks(_ values: NSSet)

    @objc(removeArtworks:)
    @NSManaged public func removeFromArtworks(_ values: NSSet)

}
