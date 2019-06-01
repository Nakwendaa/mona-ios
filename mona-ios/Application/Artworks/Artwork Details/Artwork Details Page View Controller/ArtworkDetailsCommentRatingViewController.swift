//
//  ArtworkDetailsCommentRatingViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class ArtworkDetailsCommentRatingViewController: UIViewController {

    //MARK: - Types
    struct Strings {
        private static let tableName = "ArtworkDetailsCommentRatingViewController"
        static let writeComment = NSLocalizedString("write comment", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    //MARK: - Properties
    var artwork : Artwork!
    
    //MARK: - UI Properties
    @IBOutlet weak var commentHintLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var endCommentButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        if let comment = artwork.comment {
            commentTextView.text = comment
        }
        else {
            commentTextView.text = Strings.writeComment
            commentTextView.textColor = .darkGray
        }
        ratingControl.delegate = self
        ratingControl.rating = Int(artwork.rating)
        endCommentButton.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Notifications handlers
    @objc func keyboardWasShown(notification: NSNotification) {
        endCommentButton.isHidden = false
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        endCommentButton.isHidden = true
    }
    
    //MARK: - Actions
    @IBAction func endCommentTapped(_ sender: UIButton) {
        view.endEditing(true)
    }

}

//MARK: - RatingControlDelegate
extension ArtworkDetailsCommentRatingViewController : RatingControlDelegate {
    
    func ratingControlDidChangeRating(_ ratingControl: RatingControl) {
        
        guard ratingControl.rating != 0 else {
            ratingControl.rating = 1
            return
        }
        
        guard ratingControl.rating != self.artwork.rating else {
            return
        }
        
        self.artwork.rating = Int16(ratingControl.rating)
        
        MonaAPI.shared.artwork(id: Int(self.artwork.id), rating: Int(self.artwork.rating), comment: nil, photo: nil) { (result) in
            switch result {
            case .success(_):
                log.info("Rating \"\(self.artwork.rating)\" sent successfully for artwork with id: \(self.artwork.id).")
                self.artwork.ratingSent = true
                let context = self.artwork.managedObjectContext!
                do {
                    try context.save()
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
    }
}

//MARK: - TextViewDelegate
extension ArtworkDetailsCommentRatingViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .darkGray {
            commentTextView.text = nil
            commentTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard textView.text != "" else {
            textView.textColor = .darkGray
            textView.text = Strings.writeComment
            artwork.comment = nil
            return
        }
        
        guard textView.text != artwork.comment else {
            return
        }
        
        artwork.comment = textView.text
        
        MonaAPI.shared.artwork(id: Int(self.artwork.id), rating: nil, comment: self.artwork.comment, photo: nil) { (result) in
            switch result {
            case .success(_):
                log.info("Comment \"\(self.artwork.comment ?? "")\" sent successfully for artwork with id: \(self.artwork.id).")
                self.artwork.commentSent = true
                let context = self.artwork.managedObjectContext!
                do {
                    try context.save()
                }
                catch {
                    log.error("Failed to save context: \(error)")
                }
            case .failure(let userArtworkError):
                log.error("Failed to send comment \"\(self.artwork.comment ?? "")\" for artwork with id: \(self.artwork.id).")
                log.error(userArtworkError)
                log.error(userArtworkError.localizedDescription)
            }
        }
        
    }
}
