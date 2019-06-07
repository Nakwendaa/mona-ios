//
//  BadgesViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-02.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class BadgesViewController: UIViewController {
    
    //MARK: - Types
    struct Segues {
        static let showBadgeDetailsViewController = "showBadgeDetailsViewController"
    }
    struct Strings {
        private static let tableName = "BadgesViewController"
        static let collectedArtwork = NSLocalizedString("collected artwork", tableName: tableName, bundle: .main, value: "", comment: "")
        static let collectedArtworks = NSLocalizedString("collected artworks", tableName: tableName, bundle: .main, value: "", comment: "")
        static let districts = NSLocalizedString("districts", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }

    var collectionViewCells = AppData.badges.filter { !Set([15,16,17,18,19,20,21,22,23]).contains(Int($0.id)) }
    @IBOutlet weak var collectionView: UICollectionView!
    
    var didViewLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setTransparentNavigationBar(tintColor: .black)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if didViewLoaded {
            collectionView.reloadData()
        }
        didViewLoaded = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case Segues.showBadgeDetailsViewController:
            let badgeDetailsViewController = segue.destination as! BadgeDetailsViewController
            badgeDetailsViewController.badge = sender as? Badge
        default:
            return
        }
    }

}

extension BadgesViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = collectionViewCells[indexPath.row]
        performSegue(withIdentifier: Segues.showBadgeDetailsViewController, sender: badge)
    }
}

extension BadgesViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            
            let collectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionReusableView", for: indexPath)
            
            
            let collectedArtworksCountLabel = collectionReusableView.subviews[0].subviews[0] as! UILabel
            let collectedArtworksHintLabel = collectionReusableView.subviews[0].subviews[1].subviews[0] as! UILabel
            // Categories label
            let firstCategoryCollectedArtworksCountLabel = collectionReusableView.subviews[1].subviews[0].subviews[0] as! UILabel
            let secondCategoryCollectedArtworksCountLabel = collectionReusableView.subviews[1].subviews[0].subviews[1] as! UILabel
            let thirdCategoryCollectedArtworksCountLabel = collectionReusableView.subviews[1].subviews[0].subviews[2] as! UILabel
            let firstCategoryLabel = collectionReusableView.subviews[1].subviews[1].subviews[0] as! UILabel
            let secondCategoryLabel = collectionReusableView.subviews[1].subviews[1].subviews[1] as! UILabel
            let thirdCategoryLabel = collectionReusableView.subviews[1].subviews[1].subviews[2] as! UILabel
            // Quartier
            let districtLabel = collectionReusableView.subviews[2].subviews[0] as! UILabel
            districtLabel.text = Strings.districts
            
            let collectedArtworksCount = AppData.artworks.filter({ $0.isCollected }).count
            collectedArtworksCountLabel.text = String(collectedArtworksCount)
            collectedArtworksHintLabel.text = collectedArtworksCount == 1 ? Strings.collectedArtwork : Strings.collectedArtworks

            let firstCategory = AppData.categories[0]
            firstCategoryLabel.text = firstCategory.localizedName.lowercased()
            let secondCategory = AppData.categories[1]
            secondCategoryLabel.text = secondCategory.localizedName.lowercased()
            let thirdCategory = AppData.categories[2]
            thirdCategoryLabel.text = thirdCategory.localizedName.lowercased()
            let firstCategoryCollectedArtworksCount = firstCategory.artworks.filter({ $0.isCollected }).count
            firstCategoryCollectedArtworksCountLabel.text = String(firstCategoryCollectedArtworksCount)
            let secondCategoryCollectedArtworksCount = secondCategory.artworks.filter({ $0.isCollected }).count
            secondCategoryCollectedArtworksCountLabel.text = String(secondCategoryCollectedArtworksCount)
            let thirdCategoryCollectedArtworksCount = thirdCategory.artworks.filter({ $0.isCollected }).count
            thirdCategoryCollectedArtworksCountLabel.text = String(thirdCategoryCollectedArtworksCount)
            
            return collectionReusableView
        }
        fatalError("Unexpected kind")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
        
        let imageView = collectionViewCell.subviews[0].subviews[0].subviews[0].subviews[0] as! UIImageView
        let progressionView = collectionViewCell.subviews[0].subviews[0].subviews[0].subviews[1] as! UIProgressView
        
        let badge = collectionViewCells[indexPath.row]
        if badge.isCollected {
            imageView.image = UIImage(named: badge.collectedImageName)
        }
        else {
            let image = UIImage(named: badge.notCollectedImageName)
            if image == nil {
                log.error("Badge with name \(badge.notCollectedImageName) is nil")
            }
            imageView.image = UIImage(named: badge.notCollectedImageName)
        }
        progressionView.progress = badge.progress
        
        return collectionViewCell
    }
}

extension BadgesViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (self.collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size/1.5)
    }
}
