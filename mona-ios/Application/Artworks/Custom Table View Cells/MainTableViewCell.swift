//
//  ArtworkListTableViewCell.swift
//  mona
//
//  Created by Paul Chaffanet on 2018-09-10.
//  Copyright © 2018 Lena Krause. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    struct Parameters {
        
        struct View {
            static let unselectedBackgroundColor : UIColor = .white
            static let selectedBackgroundColor : UIColor = .white
        }
        
        struct Label {
            static let unselectedTextColor : UIColor = .black
            static let selectedTextColor : UIColor = .lightGray
        }
        
        struct LineView {
            static let unselectedBackgroundColor : UIColor = UIColor(red: 254.0/255.0, green: 230.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            static let selectedBackgroundColor : UIColor = UIColor(red: 254.0/255.0, green: 230.0/255.0, blue: 51.0/255.0, alpha: 0.2)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if (selected) {
            label.textColor = Parameters.Label.selectedTextColor
            lineView.backgroundColor = Parameters.LineView.selectedBackgroundColor
        }
        else {
            label.textColor = Parameters.Label.unselectedTextColor
            lineView.backgroundColor = Parameters.LineView.unselectedBackgroundColor
        }
    }
    
}
