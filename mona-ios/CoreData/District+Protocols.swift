//
//  District+Protocols.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

extension District : TextRepresentable {
    
    var text: String {
        return name
    }
    
}

extension District : ArtworksSettable {
    
}

extension District : Fetchable {
    
}
