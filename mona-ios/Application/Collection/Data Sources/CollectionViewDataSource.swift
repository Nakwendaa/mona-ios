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
    private var indexAssets = [Int16: Int]()
    
    override init() {
        super.init()
    }
    
    //MARK: - Initializers
    init(artworks: [Artwork]) {
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
            
            // Get the last Photo added in artwork.photos for the current artwork
            guard   let photosOrderedSetForArtwork = artwork.photos,
                let lastPhotoAddedForArtwork = photosOrderedSetForArtwork.lastObject as? Photo else {
                    return
            }
            // localIdentifier is the localIdentifier of the last asset saved for the current artwork
            // index is the asset's order in the tableViewDataSource
            localIdentifiersOrdered.updateValue(index, forKey: lastPhotoAddedForArtwork.localIdentifier)
            // key: artwork.id, value: index is the artwork's order in the tableViewDataSource
            indexAssets.updateValue(index, forKey: artwork.id)
            index += 1

        }
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
        cell.artwork = artworks[indexPath.row]
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
                                                                guard let image = result else {
                                                                    cell.imageView.image = nil
                                                                    return
                                                                }
                                                                cell.imageView.image = image
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
            //print("HeaderView. Item: \(indexPath.item), Section: \(indexPath.section)")
        }
        else {
            reusableView = UICollectionReusableView()
        }
        
        return reusableView
    }
    
    //MARK: - Notification handlers
    @objc func didAddPhotoToArtwork(_ notification: Notification) {
        guard   let userInfo = notification.userInfo,
            let localIdentifier = userInfo["photo"] as? String,
            let artworkId = userInfo["artworkId"] as? Int16 else {
                return
        }
        // If an asset exists for this artwork...
        if let index = indexAssets[artworkId] {
            // Stop caching this asset
            cachingImageManager.stopCachingImages(for: [assets[index]], targetSize: CGSize(width: 44, height: 58), contentMode: .aspectFill, options: imageRequestOptions)
            // Fetch the new asset
            guard let asset = MonaPhotosAlbum.shared.fetchAsset(withLocalIdentifier: localIdentifier) else {
                return
            }
            // Set new asset
            assets[index] = asset
            // Start caching it
            cachingImageManager.startCachingImages(for: [asset], targetSize: CGSize(width: 44, height: 58), contentMode: .aspectFill, options: imageRequestOptions)
        }
            // Else an asset doesn't exist for this artwork, so we have to start caching it
        else {
            // First, let's fetch this asset with local identifier
            guard let asset = MonaPhotosAlbum.shared.fetchAsset(withLocalIdentifier: localIdentifier) else {
                return
            }
            cachingImageManager.startCachingImages(for: [asset], targetSize: CGSize(width: 44, height: 58), contentMode: .aspectFill, options: imageRequestOptions)
            indexAssets.updateValue(assets.count, forKey: artworkId)
            assets.append(asset)
        }
    }
    
    @objc func didRemovePhotoFromArtwork(_ notification: Notification) {
        guard   let userInfo = notification.userInfo,
            let localIdentifier = userInfo["photo"] as? String,
            let artworkId = userInfo["artworkId"] as? Int16 else {
                return
        }
        // If an asset exists for this artwork, and this asset that is loaded in caching manager is the one which was deleted
        if let index = indexAssets[artworkId], assets[index].localIdentifier == localIdentifier {
            
            // Stop caching this asset
            cachingImageManager.stopCachingImages(for: [assets[index]], targetSize: CGSize(width: 44, height: 58), contentMode: .aspectFill, options: imageRequestOptions)
            
            // Find the artwork with artworkId
            guard let artwork = artworks.first(where: {$0.id == artworkId}) else {
                return
            }
            
            // Find the last photo added to the artwork
            guard   let photosOrderedSetForArtwork = artwork.photos,
                    let lastPhotoAddedForArtwork = photosOrderedSetForArtwork.lastObject as? Photo else {
                    // If there is no photo associated to the artwork, remove last asset from artwork
                    assets.remove(at: index)
                    // Remove from indexAssets
                    indexAssets.removeValue(forKey: artworkId)
                    
                    // Decrement indexes
                    indexAssets.forEach { (key, value) in
                        if index < value {
                            indexAssets[key] = value - 1
                        }
                    }
                    
                    return
            }
            if let asset = MonaPhotosAlbum.shared.fetchAsset(withLocalIdentifier: lastPhotoAddedForArtwork.localIdentifier) {
                // Set the new asset with this artwork
                assets[index] = asset
                cachingImageManager.startCachingImages(for: [asset], targetSize: CGSize(width: 44, height: 58), contentMode: .aspectFill, options: imageRequestOptions)
            }
            else {
                // If there is no photo associated to the artwork, remove last asset from artwork
                assets.remove(at: index)
                // Remove from indexAssets
                indexAssets.removeValue(forKey: artworkId)
                
                // Decrement indexes
                indexAssets.forEach { (key, value) in
                    if index < value {
                        indexAssets[key] = value - 1
                    }
                }
                
                /*
                 // Recursive call to this function
                 artwork.removeFromPhotos(lastPhotoAddedForArtwork)
                 */
            }
        }
    }
}
