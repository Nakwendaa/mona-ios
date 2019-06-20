//
//  GeneralTableViewCell.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-18.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

final class GeneralTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    
    //MARK: Static
    static let reuseIdentifier = "GeneralTableViewCell"
    
    //MARK: UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var trailingMarginConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var artworks = [Artwork]()
    
    
    //MARK: - Overriden methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
