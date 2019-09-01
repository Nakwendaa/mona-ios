//
//  ArtworksTableViewDataSource.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-19.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Photos

final class ArtworksTableViewDataSource : NSObject, UITableViewDataSource, TableViewIndexDataSource {
    
    //MARK: - Types
    struct Style {
        static let indexTextColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let indexTintColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let indexFont = UIFont.boldSystemFont(ofSize: 12)
    }
    
    struct Strings {
        private static let tableName = "ArtworksTableViewDataSource"
        static let unknownTitle = NSLocalizedString("Unknown title", tableName: tableName, bundle: .main, value: "", comment: "")
        static let unknownDate = NSLocalizedString("Unknown date", tableName: tableName, bundle: .main, value: "", comment: "")
        static let unknownDistance = NSLocalizedString("Unknown distance", tableName: tableName, bundle: .main, value: "", comment: "")
        static let unkn = NSLocalizedString("unkn", tableName: tableName, bundle: .main, value: "", comment: "")
        static let lessThan100m = NSLocalizedString("Less than 100 m", tableName: tableName, bundle: .main, value: "", comment: "")
        static let lessThan1km = NSLocalizedString("Less than 1 km", tableName: tableName, bundle: .main, value: "", comment: "")
        static let lessThan5km = NSLocalizedString("Less than 5 km", tableName: tableName, bundle: .main, value: "", comment: "")
        static let lessThan10km = NSLocalizedString("Less than 10 km", tableName: tableName, bundle: .main, value: "", comment: "")
        static let moreThan10km = NSLocalizedString("More than 10 km", tableName: tableName, bundle: .main, value: "", comment: "")
    }
    
    enum SortType {
        case text
        case date
        case distance
    }

    //MARK: - Properties
    private var sections = [ArtworksSection]()
    var usingSortType : SortType = .text
    private var lastUserLocation = CLLocation(latitude: 0, longitude: 0)

    // Image Manager
    private let cachingImageManager = PHCachingImageManager()
    private var imageRequestOptions = PHImageRequestOptions()
    private var assets = [PHAsset]()
    // A mapping IndexPath to index
    // This map is used to find an asset based on artwordId. We need this dict because some artworks don't have assets
    private var indexAssets = [Int16: Int]()
    
    // Initializers
    init(artworks: [Artwork]) {
        super.init()
        sections = [ArtworksSection(name: "", items: artworks)].sortText()
            
        // Setup image request options
        imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.deliveryMode = .fastFormat
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.version = .original
        imageRequestOptions.isSynchronous = false
            
        // Setup assets
        // Key: localIdentifier, Value: order in the array
        var localIdentifiersOrdered = [String : Int]()
        // Value used to compute position of the asset
        var index = 0
        sections.forEach {
            section in
            section.items.forEach {
                artwork in
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
        }
        // We fetch assets sorted by index. Some assets in the array could be nil because they don't exist anymore in the photolibrary
        assets = MonaPhotosAlbum.shared.fetchAssets(withLocalIdentifiers: localIdentifiersOrdered).compactMap { $0 }
        
        /*
        while true {
            // Get the artworksIds whose asset fetched is nil
            let unvalidIndexAssets : [Int16 : Int] = indexAssets.filter { _, index in assets[index] == nil }
            // Find artworks associated with these ids
            let artworksWithUnvalidAsset : [Artwork] = sections.flatMap { $0.items.filter { unvalidIndexAssets.index(forKey: $0.id) != nil } }
            // A dict local Identifier (the new one for the artwork if it exists) : Index (the index in the assets)
            var newLocalIdentifiersOrdered = [String : Int]()
            // Remove last photo of their orderedset Photos because the locale identifier of this lastPhoto wasn't valid
            // Return new last localIdentifiers
            artworksWithUnvalidAsset.forEach { artwork in
                // Get the last Photo added in artwork.photos for the current artwork
                guard   let lastPhotoAddedForArtwork = artwork.photos?.lastObject as? Photo else {
                    return
                }
                // Remove it
                artwork.removeFromPhotos(lastPhotoAddedForArtwork)
                
                // Get the new last photo if it exist
                guard   let newLastPhotoAddedForArtwork = artwork.photos?.lastObject as? Photo else {
                    return
                }
                // Key: the local identifier of the last photo that we can find associated to the artwork
                // Value : the index in let assets array of PHASSet
                newLocalIdentifiersOrdered.updateValue(indexAssets[artwork.id]!, forKey: newLastPhotoAddedForArtwork.localIdentifier)
            }
            if newLocalIdentifiersOrdered.isEmpty {
                break
            }
            let newAssets = MonaPhotosAlbum.shared.fetchAssets(withLocalIdentifiers: newLocalIdentifiersOrdered).compactMap{ $0 }
            newAssets.forEach {
                // Set asset found
                assets[newLocalIdentifiersOrdered[$0.localIdentifier]!] = $0
            }
        }
        var sortedIndexAssets = indexAssets.sorted(by: { l,r in l.value < r.value })
        // Update index
        // incrementIndex = 0
        // sortedIndex[artworkId] += incrementIndex
        // Si sortedIndex[artworkId] == nil, alors incrementIndex -= -1
        var incrementIndex = 0
        var indexToRemove = [Int]()
        for (i, _) in zip(0...assets.count, sortedIndexAssets) {
            if assets[i] == nil {
                incrementIndex -= 1
                indexToRemove.append(i)
            }
            else {
                sortedIndexAssets[i].value += incrementIndex
            }
        }
        incrementIndex = 0
        indexToRemove.forEach {
            assets.remove(at: $0 + incrementIndex)
            sortedIndexAssets.remove(at: $0 + incrementIndex)
            incrementIndex -= 1
            
        }
        indexAssets = sortedIndexAssets.reduce(into: [:]) { $0[$1.0] = $1.1 }
        // We filter the not nil assets
        let existingAssets = assets.compactMap { $0 }
        self.assets = existingAssets
        */
        cachingImageManager.startCachingImages(for: assets, targetSize: CGSize(width: 44, height: 58), contentMode: .aspectFill, options: imageRequestOptions)
        NotificationCenter.default.addObserver(self, selector: #selector(didAddPhotoToArtwork(_:)), name: .didAddPhotoToArtwork, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemovePhotoFromArtwork(_:)), name: .didRemovePhotoFromArtwork, object: nil)

    }
    
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
            guard let artwork = sections.flatMap({ $0.items }).first(where: {$0.id == artworkId}) else {
                return
            }
            
            // Find the last photo added to the artwork
            guard   let photosOrderedSetForArtwork = artwork.photos,
                    let lastPhotoAddedForArtwork = photosOrderedSetForArtwork.lastObject as? Photo else {
                    // If there is no photo associated to the artwork, remove last asset from artwork
                    assets.remove(at: index)
                    // Remove from indexAssets
                    indexAssets.removeValue(forKey: artworkId)
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
                /*
                // Recursive call to this function
                artwork.removeFromPhotos(lastPhotoAddedForArtwork)
                */
            }
        }
    }
    
    //MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name.capitalizingFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtworkTableViewCell.reuseIdentifier, for: indexPath) as? ArtworkTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ArtworkTableViewCell.")
        }
        
        guard indexPath.section < sections.count, indexPath.row < sections[indexPath.section].items.count else {
            return cell
        }

        // Fetches the appropriate artwork for the data source layout.
        let artwork = sections[indexPath.section].items[indexPath.row]
        
        // Set id of the artwork for the cell
        cell.artwork = artwork
        if artwork.title == nil || artwork.title == "" {
            cell.titleLabel.text = Strings.unknownTitle
        }
        else {
            cell.titleLabel.text = artwork.title
        }
        
        // Set the subtitle of the cell
        if usingSortType == .distance {
            // If artwork are sorted by distance
            
            // Compute distance between user location (that we can find in coordinateFrom, 0,0 by default) and artwork location
            let distance = lastUserLocation.distance(from: CLLocation(latitude: artwork.address.coordinate.latitude, longitude: artwork.address.coordinate.longitude))
            
            if distance >= 1000 {
                            // If distance is more than 1000m, set subtitle of the cell in km instead of meters. Append district name to this string too.
                let distanceKm = Double(distance) / 1000.0
                cell.subtitleLabel.text = String(Double(round(100 * distanceKm) / 100)) + " km \u{25CF} " + artwork.address.district.text
            }
            else {
                // Else if distance is less than 1000m, set subtitle of the cell in m. Append district name to this string too.
                cell.subtitleLabel.text = String(Int(distance)) + " m \u{25CF} " + artwork.address.district.text
            }
        }
        else {
            // Else if artworks are NOT sorted by distance
            
            // Set district name as subtitle of the cell
            cell.subtitleLabel.text = artwork.district.text
        }
        
        // Set thumbnail for the cell
        if cell.tag != 0 {
            cachingImageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        // Get the index of the artwork's asset with artwork.id (see init())
        guard let index = indexAssets[artwork.id] else {
            cell.photoImageView.image = nil
            return cell
        }
        
        // Find the asset
        let asset = assets[index]
        
        cell.tag = Int(cachingImageManager.requestImage(for: asset,
            targetSize: cell.photoImageView.frame.size,
            contentMode: .aspectFill,
            options: nil) { (result, info) in
            cell.photoImageView.image = result
        })
        
        return cell
        
    }
    
    //MARK: - Table View Index Data Source
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        tableViewIndex.tintColor = Style.indexTintColor
        var sectionIndexViews = [UIView]()
        
        for section in sections {
            
            let label = UILabel()
            label.font = Style.indexFont
            label.textColor = Style.indexTextColor
            
            switch section.name {
                
            case Strings.lessThan100m:
                label.text = "< 100m"
            case Strings.lessThan1km:
                label.text = "< 1km"
            case Strings.lessThan5km:
                label.text = "< 5km"
            case Strings.lessThan10km:
                label.text = "< 10km"
            case Strings.moreThan10km:
                label.text = "> 10km"
            case Strings.unknownDistance:
                label.text = Strings.unkn
            default:
                return sections.map({
                    section in
                    let label = UILabel()
                    label.font = Style.indexFont
                    label.textColor = Style.indexTextColor
                    if section.name == Strings.unknownDate {
                        label.text = Strings.unkn
                    }
                    else {
                        label.text = section.name
                    }
                    return label
                })
                
            }
            sectionIndexViews.append(label)
        }
        
        
        return sectionIndexViews
    }
    
    //MARK: - Public methods
    func sort(by sort: SortType, coordinate: CLLocation?) {
        
        usingSortType = sort
        
        switch sort {
        case .text:
            sections = sections.sortText()
        case .date:
            sections = sections.sortDate()
        case .distance:
            // It is useful to save this information in order to set subtitles
            lastUserLocation = coordinate ?? CLLocation(latitude: 0, longitude: 0)
            sections = sections.sortDistance(from: lastUserLocation)
        }
        
    }
    
}
