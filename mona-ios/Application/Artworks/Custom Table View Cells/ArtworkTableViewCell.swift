//
//  ArtworkTableViewCell.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-19.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class ArtworkTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ArtworkTableViewCell"
    
    var artworkId: Int16!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var trailingMarginConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
