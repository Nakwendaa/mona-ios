//
//  CollectionViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-01.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class CollectionViewController: UIViewController, Contextualizable {
    
    //MARK: - Contextualizable
    var viewContext: NSManagedObjectContext?
    //MARK: - Properties
    var collectionViewDataSource: UICollectionViewDataSource?
    // This variable is useful to avoid unnecessary tableview.reloadData when the viewDidLoad
    var didViewLoaded = false
    //MARK: - UI properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDataSource = CollectionViewDataSource()
        collectionView.dataSource = collectionViewDataSource
        CoreDataStack.fetchAsynchronously(type: Artwork.self, context: viewContext!, entityName: "Artwork", predicate: NSPredicate(format: "isCollected == YES")) { artworks in
            self.collectionViewDataSource = CollectionViewDataSource(collectionView: self.collectionView, artworks: artworks)
            self.collectionView.dataSource = self.collectionViewDataSource
            self.collectionView.reloadData()
        }
        setTransparentNavigationBar(tintColor: .black)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didViewLoaded {
            CoreDataStack.fetchAsynchronously(type: Artwork.self, context: viewContext!, entityName: "Artwork", predicate: NSPredicate(format: "isCollected == YES")) { artworks in
                self.collectionViewDataSource = CollectionViewDataSource(collectionView: self.collectionView, artworks: artworks)
                self.collectionView.dataSource = self.collectionViewDataSource
                self.collectionView.reloadData()
            }
        }
        didViewLoaded = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
