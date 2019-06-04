//
//  BadgesDetailsViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2018-08-24.
//  Copyright © 2018 Paul Chaffanet. All rights reserved.
//

import UIKit

class BadgesDetailsViewController: UIViewController {

    struct Strings {
        private static let tableName = ""
    }
    var badge : Badge!
    
    @IBOutlet weak var badgeNameLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var collectedArtworksCountForBadgeLabel: UILabel!
    @IBOutlet weak var visitedArtworksHintLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        badgeNameLabel.text = badge.localizedName
        
        if badge.isCollected {
            badgeImageView.image = UIImage(named: badge.collectedImageName)
        }
        else {
            badgeImageView.image = UIImage(named: badge.notCollectedImageName)
        }
        
        if badge.isCollected {
            collectedArtworksCountForBadgeLabel.text = String(badge.targetValue) + "/" + String(badge.targetValue)
        }
        else {
            collectedArtworksCountForBadgeLabel.text = String(badge.currentValue) + "/" + String(badge.targetValue)
        }
        visitedArtworksHintLabel.text = NSLocalizedString("visited artworks", comment: "")
        
        if badge.isCollected {
            collectedArtworksCountForBadgeLabel.textColor = UIColor(red: 250.0/255.0, green: 217.0/255.0, blue: 1/255.0, alpha: 1)
        }
        
        navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
