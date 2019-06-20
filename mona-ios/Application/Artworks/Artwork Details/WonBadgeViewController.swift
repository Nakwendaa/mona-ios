//
//  WonBadgeViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-03.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class WonBadgeViewController: UIViewController {

    //MARK: - Properties
    var badges: [Badge]!
    
    //MARK: - UI Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNextBadge()
    }

    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
        if badges.count == 0 {
            dismiss(animated: true, completion: nil)
        }
        else {
            setupNextBadge()
        }
    }
    
    private func setupNextBadge() {
        let badge = badges.removeFirst()
        imageView.image = UIImage(named: badge.collectedImageName)
        titleLabel.text = badge.text.uppercased()
        descriptionLabel.text = badge.localizedComment
    }
}
