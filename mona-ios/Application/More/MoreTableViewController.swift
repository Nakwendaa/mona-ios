//
//  MoreTableViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-12.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

final class MoreTableViewController : UITableViewController {
    
    //MARK: - Types
    struct Strings {
        private static let tableName = "MoreTableViewController"
        static let title = NSLocalizedString("More", tableName: tableName, bundle: .main, value: "", comment: "")
        static let badges = NSLocalizedString("Badges", tableName: tableName, bundle: .main, value: "", comment: "")
        static let targeted = NSLocalizedString("Targeted", tableName: tableName, bundle: .main, value: "", comment: "")
        static let dataPrivacy = NSLocalizedString("Data privacy", tableName: tableName, bundle: .main, value: "", comment: "")
        static let about = NSLocalizedString("About", tableName: tableName, bundle: .main, value: "", comment: "")
    }
    
    struct Segues {
        static let showTargetedArtworksTableViewController = "showTargetedArtworksTableViewController"
    }
    
    //MARK: - UI Properties
    @IBOutlet weak var badgesTableViewCellLabel: UILabel!
    @IBOutlet weak var targetedTableViewCellLabel: UILabel!
    @IBOutlet weak var dataPrivacyTableViewCellLabel: UILabel!
    @IBOutlet weak var aboutTableViewCellLabel: UILabel!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        badgesTableViewCellLabel.text = Strings.badges
        targetedTableViewCellLabel.text = Strings.targeted
        dataPrivacyTableViewCellLabel.text = Strings.dataPrivacy
        aboutTableViewCellLabel.text = Strings.about
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultIosNavigationBar(tintColor: .black)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case Segues.showTargetedArtworksTableViewController:
            let artworksTableViewController = segue.destination as! ArtworksTableViewController
            artworksTableViewController.title = Strings.targeted
            DispatchQueue.main.async {
                artworksTableViewController.artworks = AppData.artworks.filter { $0.isTargeted }
            }
        default:
            break
        }
    }
}
