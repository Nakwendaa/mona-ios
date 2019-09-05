//
//  BadgesDetailsViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2018-08-24.
//  Copyright © 2018 Paul Chaffanet. All rights reserved.
//

import UIKit

class BadgeDetailsViewController: UIViewController {

    //MARK: - Types
    struct Strings {
        private static let tableName = "BadgeDetailsViewController"
        static let collectedArtworks = NSLocalizedString("collected artworks", tableName: tableName, bundle: .main, value: "", comment: "")
    }
    
    //MARK: - Properties
    var badge : Badge!
    
    //MARK: - UI Properties
    @IBOutlet weak var badgeNameLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var collectedArtworksCountForBadgeLabel: UILabel!
    @IBOutlet weak var collectedArtworksHintLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the badge name in the view.
        badgeNameLabel.text = badge.text
        
        // Set the image
        var bundlePath : String!
        if badge.isCollected {
            bundlePath = Bundle.main.path(forResource: badge.collectedImageName, ofType: "png")
        }
        else {
            bundlePath = Bundle.main.path(forResource: badge.notCollectedImageName, ofType: "png")
        }
        
        DispatchQueue.main.async {
            self.badgeImageView.image = UIImage(contentsOfFile: bundlePath)
        }
        
        if badge.isCollected {
            collectedArtworksCountForBadgeLabel.text = String(badge.targetValue) + "/" + String(badge.targetValue)
        }
        else {
            collectedArtworksCountForBadgeLabel.text = String(badge.currentValue) + "/" + String(badge.targetValue)
        }
        collectedArtworksHintLabel.text = Strings.collectedArtworks
        
        if badge.isCollected {
            collectedArtworksCountForBadgeLabel.textColor = UIColor(red: 250.0/255.0, green: 217.0/255.0, blue: 1/255.0, alpha: 1)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
