//
//  Namable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreData

protocol Namable {
    associatedtype T : NSManagedObject
    var nameNamable : String { get }
    var artworks : Set<Artwork> { get }
    static func fetchRequest() -> NSFetchRequest<T>
}

extension Namable {
    
    static func fetchRequest() -> NSFetchRequest<T> {
        return NSFetchRequest<T>(entityName: String(describing: T.self))
    }
}
