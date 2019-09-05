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

    var collectionViewCells = AppData.badges.filter { !Set([15,16,17,18,19,20,21,22,23]).contains(Int($0.id)) }.sorted(by: { $0.collectedImageName < $1.collectedImageName })
    @IBOutlet weak var collectionView: UICollectionView!
    
    var didViewLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        navigationItem.title = "Badges"
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Show title if the user scrolled below the main tableHeaderView
        let didTheUserScrolledBelowTableHeaderView = scrollView.contentOffset.y >= 8
        switch (didTheUserScrolledBelowTableHeaderView, navigationItem.titleView) {
        case (true, let titleView) where titleView != nil:
            navigationItem.titleView = nil
        case (false, nil):
            navigationItem.titleView = UIView()
        default:
            break
        }
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
            let fourthCategoryCollectedArtworksCountLabel = collectionReusableView.subviews[1].subviews[0].subviews[3] as! UILabel
            let firstCategoryLabel = collectionReusableView.subviews[1].subviews[1].subviews[0] as! UILabel
            let secondCategoryLabel = collectionReusableView.subviews[1].subviews[1].subviews[1] as! UILabel
            let thirdCategoryLabel = collectionReusableView.subviews[1].subviews[1].subviews[2] as! UILabel
            let fourthCategoryLabel = collectionReusableView.subviews[1].subviews[1].subviews[3] as! UILabel
            // Quartier
            let districtLabel = collectionReusableView.subviews[2].subviews[0] as! UILabel
            districtLabel.text = Strings.districts
            
            let collectedArtworksCount = AppData.artworks.filter({ $0.isCollected }).count
            collectedArtworksCountLabel.text = String(collectedArtworksCount)
            collectedArtworksHintLabel.text = collectedArtworksCount == 1 ? Strings.collectedArtwork : Strings.collectedArtworks

            let firstCategory = AppData.categories[0]
            firstCategoryLabel.text = firstCategory.text.lowercased()
            let secondCategory = AppData.categories[1]
            secondCategoryLabel.text = secondCategory.text.lowercased()
            let thirdCategory = AppData.categories[2]
            thirdCategoryLabel.text = thirdCategory.text.lowercased()
            let fourthCategory = AppData.categories[3]
            fourthCategoryLabel.text = fourthCategory.text.lowercased()
            let firstCategoryCollectedArtworksCount = firstCategory.artworks.filter({ $0.isCollected }).count
            firstCategoryCollectedArtworksCountLabel.text = String(firstCategoryCollectedArtworksCount)
            let secondCategoryCollectedArtworksCount = secondCategory.artworks.filter({ $0.isCollected }).count
            secondCategoryCollectedArtworksCountLabel.text = String(secondCategoryCollectedArtworksCount)
            let thirdCategoryCollectedArtworksCount = thirdCategory.artworks.filter({ $0.isCollected }).count
            thirdCategoryCollectedArtworksCountLabel.text = String(thirdCategoryCollectedArtworksCount)
            let fourthCategoryCollectedArtworksCount = fourthCategory.artworks.filter({ $0.isCollected }).count
            fourthCategoryCollectedArtworksCountLabel.text = String(fourthCategoryCollectedArtworksCount)
            
            return collectionReusableView
        }
        fatalError("Unexpected kind")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
        
        
        let badge = collectionViewCells[indexPath.row]
        
        var bundlePath : String!
        if badge.isCollected {
            bundlePath = Bundle.main.path(forResource: badge.collectedImageName, ofType: "png")
        }
        else {
            bundlePath = Bundle.main.path(forResource: badge.notCollectedImageName, ofType: "png")
        }
       
        let imageView = collectionViewCell.subviews[0].subviews[0].subviews[0].subviews[0] as! UIImageView
        let progressionView = collectionViewCell.subviews[0].subviews[0].subviews[0].subviews[1] as! UIProgressView
        
        DispatchQueue.main.async {
            imageView.image = UIImage(contentsOfFile: bundlePath!)
            progressionView.progress = badge.progress
        }
        
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
