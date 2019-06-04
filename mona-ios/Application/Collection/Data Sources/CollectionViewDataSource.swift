//
//  CollectionViewDataSource.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-01.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import Photos

class CollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    //MARK: - Properties
    private var artworks = [Artwork]()
    // Image Manager
    private let cachingImageManager = PHCachingImageManager()
    private var imageRequestOptions = PHImageRequestOptions()
    private var assets = [PHAsset]()
    
    override init() {
        super.init()
    }
    
    //MARK: - Initializers
    init(collectionView: UICollectionView, artworks: [Artwork]) {
        super.init()
        self.artworks = artworks
        // Setup image request options
        imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.deliveryMode = .fastFormat
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.version = .original
        imageRequestOptions.isSynchronous = false
        
        // Key: localIdentifier, Value: order in the array
        var localIdentifiersOrdered = [String : Int]()
        var index = 0
        artworks.forEach { artwork in
            
            let photo = artwork.photos!.lastObject! as! Photo
            localIdentifiersOrdered[photo.localIdentifier] = index
            index += 1
        }
        // We fetch assets sorted by index. Some assets in the array could be nil because they don't exist anymore in the photolibrary
        let layout = collectionView.collectionViewLayout
        //let targetSize = layout.layoutAttributesForItem(at: IndexPath(row: 0, section: 0))!.bounds.size
        assets = MonaPhotosAlbum.shared.fetchAssets(withLocalIdentifiers: localIdentifiersOrdered).compactMap { $0 }
        cachingImageManager.startCachingImages(for: assets, targetSize: CGSize(width: 100, height: 200), contentMode: .aspectFill, options: imageRequestOptions)
        NotificationCenter.default.addObserver(self, selector: #selector(didAddPhotoToArtwork(_:)), name: .didAddPhotoToArtwork, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemovePhotoFromArtwork(_:)), name: .didRemovePhotoFromArtwork, object: nil)
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artworks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MosaicCell.identifer, for: indexPath) as? MosaicCell else {
            return UICollectionViewCell()
        }
        // Set thumbnail for the cell
        if cell.tag != 0 {
            cachingImageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        if indexPath.row < assets.count {
            let asset = assets[indexPath.row]
            cell.tag = Int(cachingImageManager.requestImage(for: asset,
                                                            targetSize: cell.imageView.bounds.size,
                                                            contentMode: .aspectFill,
                                                            options: nil) { (result, info) in
                                                                cell.imageView.image = result
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView : UICollectionReusableView
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerId = "Header Collection View"
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
            reusableView = headerView
            print("HeaderView. Item: \(indexPath.item), Section: \(indexPath.section)")
        }
        else {
            reusableView = UICollectionReusableView()
        }
        
        return reusableView
    }
    
    //MARK: - Notification handlers
    @objc func didAddPhotoToArtwork(_ notification: Notification) {}
    
    @objc func didRemovePhotoFromArtwork(_ notification: Notification) {}
    
    
}

