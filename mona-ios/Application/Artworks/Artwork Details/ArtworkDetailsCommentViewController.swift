//
//  ArtworkDetailsCommentViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class ArtworkDetailsCommentViewController: UIViewController {
    
    //MARK: - Types
    struct Style {
        struct TextView {
            static let textHintColor : UIColor = .darkGray
            static let textColor : UIColor = .black
        }
    }
    
    
    struct Strings {
        private static let tableName = "ArtworkDetailsCommentViewController"
        static let comment = NSLocalizedString("comment", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let done = NSLocalizedString("done", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let writeComment = NSLocalizedString("write comment", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    //MARK: - Properties
    var artwork: Artwork!
    
    //MARK: - User Interface properties
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var validateButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        hintLabel.text = Strings.comment
        validateButton.setTitle(Strings.done, for: .normal)
        commentTextView.text = Strings.writeComment
        commentTextView.delegate = self
        commentTextView.textColor = .darkGray
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Actions
    @IBAction func validateButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        
        if artwork.comment != nil && artwork.comment != "" {
            artwork.commentSent = false
            do {
                try AppData.context.save()
            }
            catch {
                log.error("Failed to save context: \(error)")
            }
            
            /*
            MonaAPI.shared.artwork(id: Int(artwork.id), rating: nil, comment: artwork.comment, photo: nil) { (result) in
                switch result {
                case .success(_):
                    log.info("Comment sent \"\(self.artwork.comment!)\" successfully for artwork with id: \(self.artwork.id).")
                    self.artwork.commentSent = true
                    do {
                        try AppData.context.save()
                    }
                    catch {
                        log.error("Failed to save context: \(error)")
                    }
                case .failure(let userArtworkError):
                    log.error("Failed to send comment \"\(self.artwork.comment!)\" for artwork with id: \(self.artwork.id).")
                    log.error(userArtworkError)
                    log.error(userArtworkError.localizedDescription)
                }
            }
            */
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
}

//MARK: - UITextViewDelegate
extension ArtworkDetailsCommentViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Style.TextView.textHintColor {
            textView.text = nil
            textView.textColor = Style.TextView.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.textColor != Style.TextView.textHintColor && textView.text != "" {
            artwork.comment = textView.text
        }
        else {
            textView.textColor = Style.TextView.textHintColor
            textView.text = Strings.writeComment
            
        }
    }
}
