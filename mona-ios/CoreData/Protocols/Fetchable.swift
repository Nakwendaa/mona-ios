//
//  NamableFetchable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreData

protocol Fetchable where Self: NSFetchRequestResult {
    static func fetchRequest() -> NSFetchRequest<Self>
}

extension Fetchable {
    
    static func fetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: String(describing: Self.self))
    }
}
