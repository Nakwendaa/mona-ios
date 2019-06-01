//
//  DailyArtworkMapViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-06.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import MapKit

class DailyArtworkMapViewController: UIViewController {

    var artwork : Artwork!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var localizeUserButton: UIButton!
    
    struct Strings {
        // Strings file
        private static let tableName = "DailyArtworkMapViewController"
        
        // The alert controller that requires authorization to use location
        struct NeedAuthorizationLocationOpenSettings {
            static let title = NSLocalizedString("need authorization location open settings title", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let message = NSLocalizedString("need authorization location open settings message", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
    }
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLocationManager()
        setupMapView(with: artwork)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        default:
            break
        }
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
    
    //MARK: - Private methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setupMapView(with artwork: Artwork) {
        // Set the delegate
        mapView.delegate = self
        // Set initial location in Montreal
        let initialLocation = CLLocation(latitude: 45.6, longitude: -73.65)
        // Set the initial zoom
        centerOnLocation(initialLocation, regionRadius: 30000)
        // Add artwork annotation to the map
        mapView.addAnnotation(DailyArtworkAnnotation(artwork: artwork))
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
        switch CLLocationManager.authorizationStatus() {
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
        default:
            locationManager.requestWhenInUseAuthorization()
            return
        }
    }

}

//MARK: - MKMapViewDelegate
extension DailyArtworkMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "DailyArtworkAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if annotationView == nil {
            annotationView = DailyArtworkAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
}

//MARK: - CLLocationManagerDelegate
extension DailyArtworkMapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            //localizeUserButtonTapped(localizeUserButton)
        default:
            mapView.showsUserLocation = false
            return
        }
    }
}
