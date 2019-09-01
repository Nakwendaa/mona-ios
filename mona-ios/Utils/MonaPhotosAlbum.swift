//
//  MonaPhotoAlbum.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Photos

class MonaPhotosAlbum: NSObject {
    
    static let albumName = "MONA"
    static let shared = MonaPhotosAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
                
            }
            
        }
        else {
            completion(false)
        }
    }
    
    private func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
            completion(true)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: MonaPhotosAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    completion(true)
                } else {
                    // Unable to create album
                    completion(false)
                }
            }
        }
    }
    
    func fetchAsset(withLocalIdentifier localIdentifier: String) -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAllBurstAssets = false
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary, .typeiTunesSynced]
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: fetchOptions)
        return result.firstObject
    }
    

    /**
     Check if local identifiers can still return a PHAsset from the photos library
     
     - Parameters:
         - localIdentifiers: An array of assets' local identifiers whose we want to check the existence in photos library
     
     - Returns: A dictionnary with a Bool which is true if the asset's local identifier exists in library, else false, as key and a Set of local identifiers as value
     */
    func existInPhotoLibrary(localIdentifiers: [String]) -> [Bool : Set<String>] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAllBurstAssets = false
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary, .typeiTunesSynced]
        // On fetch les localIdentifiers passés en paramètres
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: fetchOptions)
        // True: les local identifiers qui existent encore dans l'album photo Mona
        // False: les local identifiers qui n'existent plus dans l'album photo Mona
        var validLocalIdentifiers = [
            true : Set<String>(),
            false : Set<String>()
        ]
        // Si un asset a pu être fetch, alors c'est qu'il existe
        // On ajoute donc les local identifiers des assets qui ont pu être fetch à true
        fetchResult.enumerateObjects { asset,_,_ in
            validLocalIdentifiers[true]?.insert(asset.localIdentifier)
        }
        localIdentifiers.forEach { localIdentifier in
            // Si on ne retrouve pas un local identifier passé en paramètre dans validLocalIdentifiers[true]
            // c'est que celui-ci n'est plus valide
            if !validLocalIdentifiers[true]!.contains(localIdentifier) {
                // On peut donc l'insérer dans false
                validLocalIdentifiers[false]!.insert(localIdentifier)
            }
        }
        return validLocalIdentifiers
    }
    
    /*
    // localIdentifiers: the key is the local identifier of PHAsset
    //                   the value is the order of the local identifier
    func fetchAssets(withLocalIdentifiers localIdentifiers: [String : Int]) -> [PHAsset?] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAllBurstAssets = false
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary, .typeiTunesSynced]
        let result = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers.map({ $0.key }), options: fetchOptions)
        
        // Because some local identifiers of localIdentifiers dictionary are not valid (for instance some local identifiers may not exist anymore in the photo library because the user deleted them), we need to check for that
        let unsortedAssets = result.objects(at: IndexSet(0..<result.count))
        var assets = [PHAsset?].init(repeating: nil, count: localIdentifiers.count)
        // With local identifier fetched from assets, find the index in dictionarry and set it in the var assets
        // Local identifiers which aren't valid anymore are nil in the var assets, otherwise we can find the asset.
        unsortedAssets.forEach { asset in
            assets[localIdentifiers[asset.localIdentifier]!] = asset
        }
        return assets
    }
    */
    
    func fetchAssets(withLocalIdentifiers localIdentifiers: [String : Int]) -> [PHAsset?] {
        // Setup fetch options
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAllBurstAssets = false
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary, .typeiTunesSynced]
        
        let result = PHAsset.fetchAssets(withLocalIdentifiers: Array(localIdentifiers.keys), options: fetchOptions)
        
        // Because some local identifiers of localIdentifiers dictionary are not valid (for instance some local identifiers may not exist anymore in the photo library because the user deleted them), we need to check for that
        let unsortedAssets = result.objects(at: IndexSet(0..<result.count))
        var assets = [PHAsset?](repeating: nil, count: localIdentifiers.count)
        // With local identifier fetched from assets, find the index in dictionarry and set it in the var assets
        // Local identifiers which aren't valid anymore are nil in the var assets, otherwise we can find the asset.
        unsortedAssets.forEach { asset in
            if let order = localIdentifiers[asset.localIdentifier] {
                assets[order] = asset
            }
        }
        return assets
    }
    
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.predicate = NSPredicate(format: "title = %@", MonaPhotosAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage, onSuccess: @escaping(String) -> Void, onFailure: @escaping(Error) -> Void) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                var localIdentifier : String = ""
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest.addAssets(enumeration)
                        localIdentifier = assetPlaceHolder!.localIdentifier
                    }
                }, completionHandler: { (success, error) in
                    if success {
                        onSuccess(localIdentifier)
                    } else {
                        onFailure(error!)
                    }
                })
                
            }
        }
    }

}
