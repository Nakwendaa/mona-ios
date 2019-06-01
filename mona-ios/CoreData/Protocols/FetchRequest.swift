//
//  FetchRequest.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-31.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreData

protocol FetchRequest : NSFetchRequestResult {
    static func fetchRequest() -> NSFetchRequest<Self>
}
