//
//  ArtworkAnnotationView.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-08.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import MapKit

class ArtworkAnnotationView : MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            setupImage(annotation: self.annotation)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        setupImage(annotation: annotation)
        // Show title (and optionnaly subtitle) of the annotation
        canShowCallout = true
        // Show information button
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        // Wrap content
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private methods
    private func setupImage(annotation: MKAnnotation?) {
        // Setup the image for the annotation view if annotation is an ArtworkAnnotation #imageLiteral(resourceName: "Target Annotation Selected")
        guard let artworkAnnotation = annotation as? ArtworkAnnotation else {
            return
        }
        
        if artworkAnnotation.artwork.isTargeted {
            image = #imageLiteral(resourceName: "Target Annotation Selected")
        }
        else if artworkAnnotation.artwork.isCollected {
            image = #imageLiteral(resourceName: "Collected Annotation Selected")
        }
        else {
            image = #imageLiteral(resourceName: "Unvisited Annotation Selected")
        }
    }
    
}
