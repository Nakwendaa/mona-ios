//
//  DailyArtworkCommentViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-06.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class DailyArtworkCommentViewController: UIViewController, UITextViewDelegate {
    
    weak var artwork: Artwork!
    
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var validateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hintLabel.text = NSLocalizedString("comment", comment: "").capitalizingFirstLetter()
        validateButton.setTitle(NSLocalizedString("done", comment: "").capitalizingFirstLetter(), for: .normal)
        commentTextView.text = NSLocalizedString("write comment", comment: "").capitalizingFirstLetter()
        commentTextView.delegate = self
        commentTextView.textColor = .darkGray
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func validateButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        if artwork.comment != nil && artwork.comment != "" {
            artwork.commentSent = false
            /*
            if currentReachabilityStatus != .notReachable  {
                
                DispatchQueue.main.async {
                    if let login = dataManager.loadLogin(), let username = login["username"], let password = login["password"]  {
                        let addCommentOperation = AddCommentOperation(withUsername: username, withPassword: password, artwork: self.artwork, withComment: self.artwork.comment!)
                        let cfg = ServiceConfig(name: "Testing", base: "http://www-etud.iro.umontreal.ca/~beaurevg/ift3150")
                        let service = Service(cfg!)
                        addCommentOperation.execute(in: service).then {
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
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - TextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .darkGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.textColor != .darkGray && textView.text != "" {
            artwork.comment = textView.text
        }
        else {
            textView.textColor = .darkGray
            textView.text = NSLocalizedString("write comment", comment: "").capitalizingFirstLetter()
            
        }
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
