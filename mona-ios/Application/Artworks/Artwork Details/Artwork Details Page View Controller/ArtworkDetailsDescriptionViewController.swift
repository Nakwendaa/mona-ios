//
//  ArtworkDetailsDescriptionViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class ArtworkDetailsDescriptionViewController: UIViewController {

    //MARK: - Types
    struct Strings {
        private static let tableName = "ArtworkDetailsDescriptionViewController"
        static let unknownArtist = NSLocalizedString("unknown artist", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownCategory = NSLocalizedString("unknown category", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownSubcategory = NSLocalizedString("unknown subcategory", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownDistrict = NSLocalizedString("unknown district", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownDimensions = NSLocalizedString("unknown dimensions", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownMaterials = NSLocalizedString("unknown materials", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownTechniques = NSLocalizedString("unknown techniques", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownDate = NSLocalizedString("unknown techniques", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    
    
    //MARK: - Properties
    var artwork : Artwork!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subcategoryLabel: UILabel!
    @IBOutlet weak var materialsLabel: UILabel!
    @IBOutlet weak var techniquesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupArtistLabel()
        setupCategoryLabel()
        setupSubcategoryLabel()
        setupDimensionsLabel()
        setupMaterialsLabel()
        setupTechniquesLabel()
    }
    
    private func setupArtistLabel() {
        
        let artistLabelAttributedText : NSMutableAttributedString
        
        // Artist
        if artwork.artists.isEmpty {
            artistLabelAttributedText = NSMutableAttributedString(string: Strings.unknownArtist + ",")
        }
        else {
            artistLabelAttributedText = NSMutableAttributedString(string: artwork.artists.map({
                $0.name ?? Strings.unknownArtist
            }).joined(separator: ", "))
        }
        
        // Date
        let dateColor = UIColor(red: 119.0/255.0, green: 131.0/255.0, blue: 130.0/255.0, alpha: 1.0)
        let attributesDate = [NSAttributedString.Key.foregroundColor: dateColor]
        
        if let date = artwork.date {
            artistLabelAttributedText.append(NSAttributedString(string: ", "))
            artistLabelAttributedText.append(NSAttributedString(string: date.toString(format: "yyyy"), attributes: attributesDate))
        }
        else {
            artistLabelAttributedText.append(NSAttributedString(string: ", "))
            artistLabelAttributedText.append(NSAttributedString(string: Strings.unknownDate))
            //artistLabel.text! += ", " + Strings.unknownDate
        }
        artistLabel.attributedText = artistLabelAttributedText
    }
    
    private func setupDimensionsLabel() {
        dimensionsLabel.text = artwork.dimensions
    }
    
    private func setupCategoryLabel() {
        categoryLabel.text = artwork.category.localizedName
    }

    private func setupSubcategoryLabel() {
        if let subcategory = artwork.subcategory {
            subcategoryLabel.text = subcategory.localizedName
        }
        else {
            subcategoryLabel.removeFromSuperview()
        }
    }
    
    private func setupMaterialsLabel() {
        if artwork.materials.isEmpty {
            materialsLabel.text = Strings.unknownMaterials
        }
        else {
            materialsLabel.text = artwork.materials.map({ $0.localizedName}).joined(separator: ", ")
        }
    }
    
    private func setupTechniquesLabel() {
        if artwork.techniques.isEmpty {
            techniquesLabel.text = Strings.unknownTechniques
        }
        else {
            techniquesLabel.text = artwork.techniques.map({ $0.localizedName}).joined(separator: ", ")
        }
    }

}
