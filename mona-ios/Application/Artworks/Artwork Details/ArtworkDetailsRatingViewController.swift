//
//  ArtworkDetailsRatingViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class ArtworkDetailsRatingViewController: UIViewController {
    
    //MARK: - Types
    struct Segues {
        static let showArtworkDetailsCommentViewController = "showArtworkDetailsCommentViewController"
    }
    
    
    struct Strings {
        private static let tableName = "ArtworkDetailsRatingViewController"
        static let rateHint = NSLocalizedString("rate hint", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let next = NSLocalizedString("next", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        private init() {}
    }
    
    
    //MARK: - Properties
    var artwork : Artwork!
    
    //MARK: - User Interface properties
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var validateButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingControl.delegate = self
        hintLabel.text = Strings.rateHint
        validateButton.setTitle(Strings.next, for: .normal)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            log.error("Segue doesn't have any identifier.")
            return
        }
        
        switch identifier {
        case Segues.showArtworkDetailsCommentViewController:
            guard let artworkDetailsCommentViewController = segue.destination as? ArtworkDetailsCommentViewController else {
                log.error("Cannot cast segue with identifier \(identifier) as ArtworkDetailsCommentViewController")
                return
            }
            artworkDetailsCommentViewController.artwork = artwork
            return
        default:
            return
        }
        
    }
    
    //MARK: - Actions
    @IBAction func validateButtonTapped(_ sender: UIButton) {
        if validateButton.isEnabled {
            
            artwork.rating = Int16(ratingControl.rating)
            artwork.ratingSent = false
            
            do {
                try AppData.context.save()
            }
            catch {
                log.error("Failed to save context: \(error)")
                return
            }
            
            MonaAPI.shared.artwork(id: Int(self.artwork.id), rating: Int(self.artwork.rating), comment: nil, photo: nil) { (result) in
                switch result {
                case .success(_):
                    log.info("Rating \"\(self.artwork.rating)\" sent successfully for artwork with id: \(self.artwork.id).")
                    self.artwork.ratingSent = true
                    do {
                        try AppData.context.save()
                    }
                    catch {
                        log.error("Failed to save context: \(error)")
                    }
                case .failure(let userArtworkError):
                    log.error("Failed to send rating \"\(self.artwork.rating)\" for artwork with id: \(self.artwork.id).")
                    log.error(userArtworkError)
                    log.error(userArtworkError.localizedDescription)
                }   
            }
            
            performSegue(withIdentifier: Segues.showArtworkDetailsCommentViewController, sender: self)
        }
    }
    
}

//MARK: - RatingControlDelegate
extension ArtworkDetailsRatingViewController : RatingControlDelegate {
    
    func ratingControlDidChangeRating(_ ratingControl: RatingControl) {
        // Enable validate button only if rating is different of 0 (it does mean the minimum rate is 1 in order to validate a rating)
        validateButton.isEnabled = (ratingControl.rating != 0)
        // N
    }
}
