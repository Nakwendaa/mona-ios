//
//  LegendPopoverViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-21.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import MapKit

final class LegendPopoverViewController: UIViewController {
    
    //MARK: - Types
    private struct Strings {
        private static let tableName = "LegendPopoverViewController"
        static let collected = NSLocalizedString("Collected", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let targeted = NSLocalizedString("Targeted", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unvisited = NSLocalizedString("Unvisited", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }

    //MARK: - Properties
    var artworks = [Artwork]()
    
    // C'est bourrin, à check pour les 4 var suivantes
    weak var mapVc : MapViewController? = nil
    var collectedButtonIsSelected = true
    var unvisitedButtonIsSelected = true
    var targetedButtonIsSelected = true
    
    //MARK: UI properties
    weak var mapView : MKMapView!
    @IBOutlet weak var collectedButton: UIButton!
    @IBOutlet weak var unvisitedButton: UIButton!
    @IBOutlet weak var targetedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup titles buttton
        collectedButton.setTitle(Strings.collected, for: .normal)
        targetedButton.setTitle(Strings.targeted, for: .normal)
        unvisitedButton.setTitle(Strings.unvisited, for: .normal)
        collectedButton.isSelected = collectedButtonIsSelected
        unvisitedButton.isSelected = unvisitedButtonIsSelected
        targetedButton.isSelected = targetedButtonIsSelected
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
        // 000
        else {
            var artworksToAdd = Set<Artwork>()
            let artworksToRemove = Set<Artwork>.init(artworks)
            
            updateMap(artworksToAdd: &artworksToAdd, artworksToRemove: artworksToRemove)
        }
        
        // Laid, à check
        mapVc?.collectedButtonIsSelected = collectedButton.isSelected
        mapVc?.unvisitedButtonIsSelected = unvisitedButton.isSelected
        mapVc?.targetedButtonIsSelected = targetedButton.isSelected
        //...
    }
    
}

//MARK: - UIAdaptivePresentationControllerDelegate
extension LegendPopoverViewController : UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}
