//
//  ArtworkTableViewCell.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-19.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

final class ArtworkTableViewCell: UITableViewCell {
    
    //MARK: - Static properties
    static let reuseIdentifier = "ArtworkTableViewCell"
    
    //MARK: - Properties
    var artwork: Artwork!
    
    //MARK: - UI Properties
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var trailingMarginConstraint: NSLayoutConstraint!
    
    //MARK: - Overriden methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
