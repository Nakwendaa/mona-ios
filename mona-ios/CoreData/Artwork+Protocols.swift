//
//  Artwork+Protocols.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-04.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreLocation

extension Artwork : TextRepresentable {
    
    static let unknownTitle = NSLocalizedString("Unknown title", tableName: "Artwork+Protocols", bundle: .main, value: "", comment: "")
    
    var text : String {
        return title ?? Artwork.unknownTitle
    }
    
}

extension Artwork : DateRepresentable {}

extension Artwork : LocationRepresentable {
   
    var location: CLLocation {
        return CLLocation(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude)
    }
    
}
