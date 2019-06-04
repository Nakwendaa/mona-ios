//
//  Contextualizable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreData

protocol Contextualizable {
    var viewContext : NSManagedObjectContext? { get set }
}

var viewContext: NSManagedObjectContext?
