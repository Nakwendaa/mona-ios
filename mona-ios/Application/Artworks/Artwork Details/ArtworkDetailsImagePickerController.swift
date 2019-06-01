//
//  ArtworkDetailsImagePickerViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class ArtworkDetailsImagePickerController: UIImagePickerController {
    
    weak var artwork: Artwork?
    var onSuccess: (() -> Void)?
    var onFailure: ((Error) -> Void)?
    var artworkDetailsImagePickerControllerDelegate : ArtworkDetailsImagePickerControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artworkDetailsImagePickerControllerDelegate = ArtworkDetailsImagePickerControllerDelegate(artwork: artwork, onSuccess: onSuccess, onFailure: onFailure)
        delegate = artworkDetailsImagePickerControllerDelegate
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArtworkDetailsRatingViewController" {
            let artworkDetailsRatingViewController = segue.destination as! ArtworkDetailsRatingViewController
            artworkDetailsRatingViewController.artwork = artwork
        }
    }
    
}
