//
//  DailyArtworkImagePickerController.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-06.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class DailyArtworkImagePickerController: UIImagePickerController {
    
    var artwork: Artwork!
    var dailyArtworkImagePickerControllerDelegate : DailyArtworkImagePickerControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        dailyArtworkImagePickerControllerDelegate = DailyArtworkImagePickerControllerDelegate(artwork: artwork)
        delegate = dailyArtworkImagePickerControllerDelegate
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDailyArtworkRatingViewController" {
            let dailyArtworkRatingViewController = segue.destination as! DailyArtworkRatingViewController
            dailyArtworkRatingViewController.artwork = artwork
        }
    }

}
