//
//  ArtworkDetailsMapViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import MapKit

class ArtworkDetailsMapViewController: UIViewController {

    //MARK: - Types
    struct Segues {
        static let showArtworkDetailsFullMapViewController = "showArtworkDetailsFullMapViewController"
    }
    
    
    //MARK: - Properties
    var artwork : Artwork!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if  segue.identifier == Segues.showArtworkDetailsFullMapViewController,
            let vc = segue.destination as? ArtworkDetailsFullMapViewController {
            vc.artwork = artwork
        }
    }
    
    //MARK: - Private methods
    private func setupMapView() {
        // Set initial location to the artwork
        let initialLocation = CLLocation(latitude: artwork.address.coordinate.latitude, longitude: artwork.address.coordinate.longitude)
        // Set the initial zoom
        centerOnLocation(initialLocation, regionRadius: 300)
        // Add artwork annotation
        mapView.delegate = self
        
        mapView.addAnnotation(ArtworkDetailsAnnotation(artwork: artwork))
    }
    
    private func centerOnLocation(_ location: CLLocation, regionRadius radius: Double) {
        let regionRadius = CLLocationDistance(radius)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

//MARK: - MKMapViewDelegate
extension ArtworkDetailsMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "ArtworkDetailsAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if annotationView == nil {
            annotationView = ArtworkDetailsAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
}
