//
//  Artist+TextRepresentable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

extension Artist : TextRepresentable {
    
    static let unknownArtist = NSLocalizedString("unknown artist", tableName: "Artist+Protocols", bundle: .main, value: "", comment: "")
    
    var text: String {
        return name ?? Artist.unknownArtist
    }
}

extension Artist : ArtworksSettable {
    
}

extension Artist : Fetchable {
    
}
