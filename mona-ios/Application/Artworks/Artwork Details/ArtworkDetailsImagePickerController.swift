//
//  ArtworkDetailsImagePickerViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class ArtworkDetailsImagePickerController: UIImagePickerController, Contextualizable {
    
    
    //MARK: - Types
    struct Segues {
        static let showArtworkDetailsRatingViewController = "showArtworkDetailsRatingViewController"
        static let presentWonBadge = "presentWonBadge"
    }
    
    weak var artwork: Artwork?
    //MARK: - Contextualizable
    var viewContext: NSManagedObjectContext?
    var onSuccess: (() -> Void)?
    var onFailure: ((Error) -> Void)?
    var artworkDetailsImagePickerControllerDelegate : ArtworkDetailsImagePickerControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artworkDetailsImagePickerControllerDelegate = ArtworkDetailsImagePickerControllerDelegate(artwork: artwork, onSuccess: onSuccess, onFailure: onFailure)
        artworkDetailsImagePickerControllerDelegate.viewContext = viewContext
        delegate = artworkDetailsImagePickerControllerDelegate
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.showArtworkDetailsRatingViewController {
            let artworkDetailsRatingViewController = segue.destination as! ArtworkDetailsRatingViewController
            artworkDetailsRatingViewController.artwork = artwork
        }
        else if segue.identifier == Segues.presentWonBadge {
            let navigationController = segue.destination as! UINavigationController
            let wonBadgeViewController = navigationController.viewControllers[0] as! WonBadgeViewController
            wonBadgeViewController.badges = sender as? [Badge]
        }
    }
    
}
