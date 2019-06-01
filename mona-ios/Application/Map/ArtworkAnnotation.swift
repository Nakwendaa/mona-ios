//
//  ArtworkAnnotation.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-08.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import MapKit

class ArtworkAnnotation : NSObject, MKAnnotation {
    
    //MARK: - Types
    struct Strings {
        private static let tableName = "ArtworkAnnotation"
        static let unknownTitle = NSLocalizedString("unknown title", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    
    //MARK: - Properties
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
        if let title = artwork.title {
            // If the artwork's title is not nil, set the annotation’s title with artwork's title
            self.title = title
        }
        else {
            // If the artwork's title is nil, set the annotation’s title with the localized string defined for an unknown title
            title = Strings.unknownTitle
        }

        // Setup the annotation's coordinate
        coordinate = CLLocationCoordinate2D(latitude: artwork.address.coordinate.latitude, longitude: artwork.address.coordinate.longitude)
        
        // Call super initializer
        super.init()
    }
}
