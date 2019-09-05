//
//  MapViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-07.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: SearchViewController {
    
    //MARK: - Types
    struct Strings {
        private static let tableName = "MapViewController"
        // The alert controller that requires authorization to use location
        struct NeedAuthorizationLocationOpenSettings {
            static let title = NSLocalizedString("need authorization location open settings title", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let message = NSLocalizedString("need authorization location open settings message", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
        
    }
    
    
    struct Segues {
        static let showArtworkDetailsViewController = "showArtworkDetailsViewController"
    }
    
    //MARK: - Properties
    var viewContext: NSManagedObjectContext?
    let locationManager = CLLocationManager()
    var artworks : [Artwork] = AppData.artworks
    var legendPopoverViewController : LegendPopoverViewController?
    
    var collectedButtonIsSelected = true
    var unvisitedButtonIsSelected = true
    var targetedButtonIsSelected = true
    
    //MARK: - UI Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var localizeUserButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        // Set the delegate
        mapView.delegate = self
        // Set initial location in Montreal
        let initialLocation = CLLocation(latitude: 45.6, longitude: -73.65)
        // Set the initial zoom
        centerOnLocation(initialLocation, regionRadius: 30000)
        mapView.addAnnotations(artworks.map{ ArtworkAnnotation(artwork: $0)})
        setTransparentNavigationBar(tintColor: .black)
        filterButton.layer.cornerRadius = 5.0
        filterButton.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        filterButton.layer.shadowRadius = 1
        filterButton.layer.shadowOpacity = 0.25
    }
    
    //MARK: - Overriden methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //hideNavigationBar()
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            fallthrough
        default:
            refreshMapView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //showNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        legendPopoverViewController?.dismiss(animated: true) {
            self.legendPopoverViewController = nil
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        // Pass context
        if var contextualizableViewController = segue.destination as? Contextualizable {
            contextualizableViewController.viewContext = viewContext
        }
        
        switch identifier {
        case Segues.showArtworkDetailsViewController:
            // Check if destination's segue is ArtworkDetailsViewController
            guard let vc = segue.destination as? ArtworkDetailsViewController else {
                log.error("Destination's segue with identifier \"\(Segues.showArtworkDetailsViewController)\" is not ArtworkDetailsViewController")
                return
            }
            // Check if sender is ArtworkAnnotation
            guard let artworkAnnotation = sender as? ArtworkAnnotation else {
                log.error("Sender is not ArtworkAnnotation")
                return
            }
            // Set artwork for ArtworkDetailsViewController
            vc.artwork = artworkAnnotation.artwork
            return
        default:
            return
        }
        
    }
    
    //MARK: - Private methods
    private func showNavigationBar() {
        navigationController?.navigationBar.isHidden = false
    }
    
    private func hideNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    private func centerOnLocation(_ location: CLLocation, regionRadius radius: Double) {
        let regionRadius = CLLocationDistance(radius)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: - Actions
    @IBAction func localizeUserButtonTapped(_ sender: UIButton) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .denied, .restricted:
            UIAlertController.presentOpenSettings(
                from: self,
                title: Strings.NeedAuthorizationLocationOpenSettings.title,
                message: Strings.NeedAuthorizationLocationOpenSettings.message,
                cancelCompletion: nil,
                openSettingsCompletion: nil,
                presentCompletion: nil
            )
            return
        case .authorizedWhenInUse, .authorizedAlways:
            guard let location = mapView.userLocation.location else {
                log.debug("Cannot get userLocation.")
                return
            }
            centerOnLocation(location, regionRadius: 300)
        @unknown default:
            return
        }
    }
    
    
    @IBAction func filterTapped(_ sender: UIButton) {
        legendPopoverViewController = LegendPopoverViewController()
        // Laid, à check
        legendPopoverViewController!.mapVc = self
        legendPopoverViewController?.collectedButtonIsSelected = collectedButtonIsSelected
        legendPopoverViewController?.unvisitedButtonIsSelected = unvisitedButtonIsSelected
        legendPopoverViewController?.targetedButtonIsSelected = targetedButtonIsSelected
        //
        legendPopoverViewController!.artworks = artworks
        legendPopoverViewController!.mapView = mapView
        legendPopoverViewController!.preferredContentSize = CGSize(width: 180, height: 132)
        legendPopoverViewController!.modalPresentationStyle = .popover
        
        if let presentationController = legendPopoverViewController!.presentationController {
            presentationController.delegate = legendPopoverViewController
        }
        
        if let popoverPresentationController = legendPopoverViewController!.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
            popoverPresentationController.passthroughViews = [view]
        }
        
        present(legendPopoverViewController!, animated: true)
    }
    
    
}

//MARK: - MKMapViewDelegate
extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "ArtworkAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if annotationView == nil {
            annotationView = ArtworkAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            guard let artworkAnnotation = view.annotation as? ArtworkAnnotation else {
                log.error("Annotation is not an ArtworkAnnotation.")
                return
            }
            performSegue(withIdentifier: Segues.showArtworkDetailsViewController, sender: artworkAnnotation)
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            localizeUserButtonTapped(localizeUserButton)
        default:
            mapView.showsUserLocation = false
            return
        }
    }
    
    private func refreshMapView() {
        let annotations = mapView.annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
}

