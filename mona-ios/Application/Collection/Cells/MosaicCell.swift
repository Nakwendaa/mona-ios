/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Collection view cell subclass representing a single image.
*/

import UIKit

class MosaicCell: UICollectionViewCell {
    
    static let identifer = "MosaicCollectionViewCell"

    var imageView = UIImageView()
    var artwork : Artwork!
    var assetIdentifier: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
        autoresizesSubviews = true
        
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        
        // Use a random background color.
        //let redColor = CGFloat(arc4random_uniform(255)) / 255.0
        //let greenColor = CGFloat(arc4random_uniform(255)) / 255.0
        //let blueColor = CGFloat(arc4random_uniform(255)) / 255.0
        let redColor = CGFloat(230.0) / 255.0
        let greenColor = CGFloat(230.0) / 255.0
        let blueColor = CGFloat(230.0) / 255.0
        backgroundColor = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        assetIdentifier = nil
    }
}
