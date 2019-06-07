//
//  Artwork+Namable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-04.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

extension Artwork : Namable {
    
    var nameNamable : String {
        guard let title = title else {
            guard let language = UserDefaults.Parameters.get(forKey: .lang) else {
                return "Unknown"
            }
            switch language {
            case .en:
                return "Untitled"
            case .fr:
                return "Non titré"
            }
        }
        return title
    }
    
}
