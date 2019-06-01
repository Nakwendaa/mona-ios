//
//  DailyArtworkRatingViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-06.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class DailyArtworkRatingViewController: UIViewController, RatingControlDelegate {
    
    //MARK: - Properties
    weak var artwork : Artwork!
    
    //MARK: - User Interface properties
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var validateButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingControl.delegate = self
        hintLabel.text = NSLocalizedString("rate hint", comment: "").capitalizingFirstLetter()
        validateButton.setTitle(NSLocalizedString("next", comment: "").capitalizingFirstLetter(), for: .normal)
    }
    
    //MARK: - Actions
    @IBAction func validateButtonTapped(_ sender: UIButton) {
        if validateButton.isEnabled {
            //let storyboard = UIStoryboard(name: "Application", bundle: nil)
            //let commentViewController = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            //artwork.rating = ratingControl.rating
            //artwork.ratingSent = false
            //dataManager.saveCachedArtwork(artwork)
            
            /*
            if currentReachabilityStatus != .notReachable  {
                DispatchQueue.main.async {
                    if let login = dataManager.loadLogin(), let username = login["username"], let password = login["password"] {
                        let addNoteOperation = AddNoteOperation(withUsername: username, withPassword: password, artwork: self.artwork, withRating: self.artwork.rating!)
                        let cfg = ServiceConfig(name: "Testing", base: "http://www-etud.iro.umontreal.ca/~beaurevg/ift3150")
                        let service = Service(cfg!)
                        addNoteOperation.execute(in: service).then {
                            }.catch({
                                error in
                                log.error("Error: " + error.localizedDescription)
                            })
                    }
                    else {
                        log.error("Unable to load login info.")
                    }
                }
            }
            */
            
            
            
            //commentViewController.artwork = artwork
            performSegue(withIdentifier: "showDailyArtworkCommentViewController", sender: self)
        }
    }

    //MARK: - RatingControlDelegate
    func ratingControlDidChangeRating(_ ratingControl: RatingControl) {
        validateButton.isEnabled = (ratingControl.rating != 0)
    }
    
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDailyArtworkCommentViewController" {
            let dailyArtworkCommentViewController = segue.destination as! DailyArtworkCommentViewController
            dailyArtworkCommentViewController.artwork = artwork
        }
     }

    
}
