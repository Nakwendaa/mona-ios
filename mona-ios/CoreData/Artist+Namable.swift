//
//  Artist+Namable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

extension Artist : FetchableNamable {
    
    var nameNamable: String {
        guard let name = name else {
            return NSLocalizedString("unknown artist", tableName: "GeneralTableViewController", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
        return name
    }
    
    typealias T = Artist
    
}
