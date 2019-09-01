//
//  District+Protocols.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

extension District : TextRepresentable {
    
    static let unknownDistrict = NSLocalizedString("Unknown district", tableName: "District+Protocols", bundle: .main, value: "", comment: "")
    
    var text: String {
        return name ?? District.unknownDistrict
    }
    
}

extension District : ArtworksSettable {
    
}

extension District : Fetchable {
    
}
