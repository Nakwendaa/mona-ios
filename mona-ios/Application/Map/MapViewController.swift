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
        
        /*
        struct Legend {
            static let collected = NSLocalizedString("collected", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let targeted = NSLocalizedString("targeted", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let unvisited = NSLocalizedString("unvisited", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
        */
    }
    
    /*
    struct Style {
        struct Legend {
            struct Layer {
                static let cornerRadius : CGFloat = 30
                static let shadowColor : CGColor = UIColor.black.cgColor
                static let shadowOffset : CGSize = CGSize(width: 1, height: 5)
                static let shadowOpacity : Float = 0.5
                static let shadowRadius : CGFloat = 5
            }
        }
    }
    */
    
    struct Segues {
        static let showArtworkDetailsViewController = "showArtworkDetailsViewController"
    }
    
    //MARK: - Properties
    var viewContext: NSManagedObjectContext?
    let locationManager = CLLocationManager()
    var artworks : [Artwork] = AppData.artworks
    var legendPopoverViewController : LegendPopoverViewController?
    
    //MARK: - UI Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var localizeUserButton: UIButton!
    @IBOutlet weak var collectedButton: UIButton!
    @IBOutlet weak var unvisitedButton: UIButton!
    @IBOutlet weak var targetedButton: UIButton!
    
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
        setupLegendView()
        setTransparentNavigationBar(tintColor: .black)
    }
    
    //MARK: - Overriden methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //hideNavigationBar()
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        default:
            break
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
    
    private func setupLegendView() {
        // Setup legend view style
        //legendView.layer.cornerRadius = Style.Legend.Layer.cornerRadius
        //legendView.layer.shadowColor = Style.Legend.Layer.shadowColor
        //legendView.layer.shadowOffset = Style.Legend.Layer.shadowOffset
        //legendView.layer.shadowOpacity = Style.Legend.Layer.shadowOpacity
        //legendView.layer.shadowRadius = Style.Legend.Layer.shadowRadius
        
        // Setup titles buttton
        //collectedButton.setTitle(Strings.Legend.collected, for: .normal)
        //unvisitedButton.setTitle(Strings.Legend.unvisited, for: .normal)
        //targetedButton.setTitle(Strings.Legend.targeted, for: .normal)
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
            UIAlertController.presentOpenSettings(from: self,
                                                  title: Strings.NeedAuthorizationLocationOpenSettings.title,
                                                  message: Strings.NeedAuthorizationLocationOpenSettings.message,
                                                  completion: nil)
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
    
    
    @IBAction func legendTappedd(_ sender: UIButton) {
        legendPopoverViewController = LegendPopoverViewController()
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
    
    @IBAction func legendTapped(_ sender: UIButton) {
        
        func updateMap( artworksToAdd : inout Set<Artwork>, artworksToRemove: Set<Artwork>) {
            
            var annotationsToRemove = [MKAnnotation]()
            var annotationsToAdd = [MKAnnotation]()
            
            for annotation in mapView.annotations {
                if let artworkAnnotation = annotation as? ArtworkAnnotation {
                    // On est dans la map et contient une annotation à remove
                    if artworksToRemove.contains(artworkAnnotation.artwork) {
                        annotationsToRemove.append(artworkAnnotation)
                    }
                    // L'annotation est sur la map
                    artworksToAdd.remove(artworkAnnotation.artwork)
                }
            }
            
            artworksToAdd.forEach({
                annotationsToAdd.append(ArtworkAnnotation(artwork: $0))
            })
            
            mapView.removeAnnotations(annotationsToRemove)
            mapView.addAnnotations(annotationsToAdd)
            
        }
        
        sender.isSelected = !sender.isSelected
        
        
        // 001
        if !collectedButton.isSelected && !targetedButton.isSelected && unvisitedButton.isSelected {
            
            var artworksToAdd = Set<Artwork>()
            var artworksToRemove = Set<Artwork>()
            
            artworks.forEach({
                if !$0.isCollected && !$0.isTargeted {
                    artworksToAdd.update(with: $0)
                }
                else {
                    artworksToRemove.update(with: $0)
                }
            })
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
        }
        // 010
        else if !collectedButton.isSelected && targetedButton.isSelected && !unvisitedButton.isSelected {
            
            var artworksToAdd = Set<Artwork>()
            var artworksToRemove = Set<Artwork>()
            
            artworks.forEach({
                if $0.isTargeted {
                    artworksToAdd.update(with: $0)
                }
                else {
                    artworksToRemove.update(with: $0)
                }
            })
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
            
        }
        // 011
        else if !collectedButton.isSelected && targetedButton.isSelected && unvisitedButton.isSelected {
            
            var artworksToAdd = Set<Artwork>()
            var artworksToRemove = Set<Artwork>()
            
            artworks.forEach({
                if !$0.isCollected {
                    artworksToAdd.update(with: $0)
                }
                else {
                    artworksToRemove.update(with: $0)
                }
            })
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
        }
        // 100
        else if collectedButton.isSelected && !targetedButton.isSelected && !unvisitedButton.isSelected {
            
            var artworksToAdd = Set<Artwork>()
            var artworksToRemove = Set<Artwork>()
            
            artworks.forEach({
                if $0.isCollected {
                    artworksToAdd.update(with: $0)
                }
                else {
                    artworksToRemove.update(with: $0)
                }
            })
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
            
        }
        // 101
        else if collectedButton.isSelected && !targetedButton.isSelected && unvisitedButton.isSelected {
            
            var artworksToAdd = Set<Artwork>()
            var artworksToRemove = Set<Artwork>()
            
            artworks.forEach({
                if $0.isCollected || !$0.isTargeted {
                    artworksToAdd.update(with: $0)
                }
                else {
                    artworksToRemove.update(with: $0)
                }
            })
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
        }
        // 110
        else if collectedButton.isSelected && targetedButton.isSelected && !unvisitedButton.isSelected  {
            
            var artworksToAdd = Set<Artwork>()
            var artworksToRemove = Set<Artwork>()
            
            artworks.forEach({
                if $0.isCollected || $0.isTargeted {
                    artworksToAdd.update(with: $0)
                }
                else {
                    artworksToRemove.update(with: $0)
                }
            })
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
        }
        // 111
        else if collectedButton.isSelected && targetedButton.isSelected && unvisitedButton.isSelected {
            var artworksToAdd = Set<Artwork>.init(artworks)
            let artworksToRemove = Set<Artwork>()
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
        }
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
}

