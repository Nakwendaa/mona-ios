//
//  DailyArtworkAnnoted.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-06.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import MapKit

class DailyArtworkAnnotation : NSObject, MKAnnotation {
    
    // The artwork associated to the annotation
    var artwork: Artwork
    // The string containing the annotation’s title.
    var title : String?
    // The string containing the annotation’s subtitle.
    var subtitle: String?
    // The annotation's coordinate.
    var coordinate: CLLocationCoordinate2D
    
    init(artwork: Artwork) {
        // Setup the artwork associated to the annotation
        self.artwork = artwork
        // Setup the annotation's title
        title = artwork.title
        // Setup the annotation's coordinate
        coordinate = CLLocationCoordinate2D(latitude: artwork.address.coordinate.latitude, longitude: artwork.address.coordinate.longitude)
        super.init()
    }
}
