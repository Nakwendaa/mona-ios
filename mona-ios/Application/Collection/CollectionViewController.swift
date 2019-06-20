//
//  CollectionViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-01.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class CollectionViewController: SearchViewController {
    
    //MARK: - Properties
    private struct Segues {
        static let showArtworkDetailsViewController = "showArtworkDetailsViewController"
    }
    
    var collectionViewDataSource: UICollectionViewDataSource?
    // This variable is useful to avoid unnecessary tableview.reloadData when the viewDidLoad
    var didViewLoaded = false
    //MARK: - UI properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var heightHeaderCollectionView : CGFloat = 0
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectedArtworks = AppData.artworks.filter { $0.isCollected }
        collectionViewDataSource = CollectionViewDataSource(artworks: collectedArtworks)
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = self
        setTransparentNavigationBar(tintColor: .black)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didViewLoaded {
            let collectedArtworks = AppData.artworks.filter { $0.isCollected }
            collectionViewDataSource = CollectionViewDataSource(artworks: collectedArtworks)
            collectionView.dataSource = self.collectionViewDataSource
            collectionView.reloadData()
        }
        didViewLoaded = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        heightHeaderCollectionView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first?.bounds.height ?? 0
        print(heightHeaderCollectionView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.showArtworkDetailsViewController:
            let destination = segue.destination as! ArtworkDetailsViewController
            let cell = sender as! MosaicCell
            destination.title = cell.artwork.title
            destination.artwork = cell.artwork
        default:
            break
        }
    }

}

extension CollectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "showArtworkDetailsViewController", sender: collectionView.cellForItem(at: indexPath))
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        filterPopoverViewController?.dismiss(animated: true) {
            self.filterPopoverViewController = nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Show title if the user scrolled below the main tableHeaderView
        let didTheUserScrolledBelowTableHeaderView = scrollView.contentOffset.y >= heightHeaderCollectionView
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
