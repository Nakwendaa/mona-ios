//
//  NamableFetchable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreData

protocol FetchableNamable : ArtworksNamable {
    associatedtype T : NSManagedObject
    static func fetchRequest() -> NSFetchRequest<T>
}

extension FetchableNamable {
    
    static func fetchRequest() -> NSFetchRequest<T> {
        return NSFetchRequest<T>(entityName: String(describing: T.self))
    }
}
