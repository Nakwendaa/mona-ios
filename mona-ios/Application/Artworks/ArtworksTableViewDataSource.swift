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

class ArtworksTableViewDataSource : NSObject, UITableViewDataSource, TableViewIndexDataSource {
    
    //MARK: - Types
    struct Style {
        static let indexTextColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let indexTintColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let indexFont = UIFont.boldSystemFont(ofSize: 12)
    }
    
    struct Strings {
        static let unknownTitle = NSLocalizedString("untitled", tableName: "ArtworksTableViewDataSource", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownDate = NSLocalizedString("unknown{fem}{one}", tableName: "ArtworksTableViewDataSource", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unkn = NSLocalizedString("unkn", tableName: "ArtworksTableViewDataSource", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    
    struct Section {
        var name : String
        var items : [Artwork]
    }
    
    enum Sort {
        case title
        case date
        case distance
    }
    
    //MARK: -  properties
    private var sortUsed : Sort = .title
    private var coordinateFrom = CLLocation(latitude: 0, longitude: 0)

    //MARK: - Properties
    private var sections = [Section]()

    // Image Manager
    private let cachingImageManager = PHCachingImageManager()
    private var imageRequestOptions = PHImageRequestOptions()
    private var assets = [PHAsset]()
    // A mapping IndexPath to index
    // This map is used to find an asset based on artwordId. We need this dict because some artwork don't have assets
    private var indexAssets = [Int16: Int]()
    
    // Initializers
    init(artworks: [Artwork]) {
        super.init()
        sections = sectionsByTitle(artworks: artworks)
            
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
                // Recursive call to this function
                artwork.removeFromPhotos(lastPhotoAddedForArtwork)
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

        // Fetches the appropriate artwork for the data source layout.
        let artwork = sections[indexPath.section].items[indexPath.row]
        
        // Set id of the artwork for the cell
        cell.artworkId = artwork.id
        if artwork.title == nil || artwork.title == "" {
            cell.titleLabel.text = Strings.unknownTitle
        }
        else {
            cell.titleLabel.text = artwork.title
        }
        
        // Set the subtitle of the cell
        if sortUsed == .distance {
            // If artwork are sorted by distance
            
            // Compute distance between user location (that we can find in coordinateFrom, 0,0 by default) and artwork location
            let distance = coordinateFrom.distance(from: CLLocation(latitude: artwork.address.coordinate.latitude, longitude: artwork.address.coordinate.longitude))
            
            if distance >= 1000 {
                            // If distance is more than 1000m, set subtitle of the cell in km instead of meters. Append district name to this string too.
                let distanceKm = Double(distance) / 1000.0
                cell.subtitleLabel.text = String(Double(round(100 * distanceKm) / 100)) + " km \u{25CF} " + artwork.address.district.name
            }
            else {
                // Else if distance is less than 1000m, set subtitle of the cell in m. Append district name to this string too.
                cell.subtitleLabel.text = String(Int(distance)) + " m \u{25CF} " + artwork.address.district.name
            }
        }
        else {
            // Else if artworks are NOT sorted by distance
            
            // Set district name as subtitle of the cell
            cell.subtitleLabel.text = artwork.district.name
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
                
            case NSLocalizedString("less than 100 m", comment: "").capitalizingFirstLetter():
                label.text = "< 100m"
                break
                
            case NSLocalizedString("less than 1 km", comment: "").capitalizingFirstLetter():
                label.text = "< 1km"
                break
                
            case NSLocalizedString("less than 5 km", comment: "").capitalizingFirstLetter():
                label.text = "< 5km"
                break
                
            case NSLocalizedString("less than 10 km", comment: "").capitalizingFirstLetter():
                label.text = "< 10km"
                break
                
            case NSLocalizedString("more than 10 km", comment: "").capitalizingFirstLetter():
                label.text = "> 10km"
                break
                
            case NSLocalizedString("unknown{fem}{other}", comment: "").capitalizingFirstLetter():
                label.text = NSLocalizedString("unkn", comment: "")
                break
                
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
    func sort(by sort: Sort, coordinate: CLLocation?) {
        let artworks = sections.flatMap({$0.items})
        switch sort {
        case .title:
            sortUsed = .title
            sections = sectionsByTitle(artworks: artworks)
            break
        case .date:
            sortUsed = .date
            sections = sectionsByDate(artworks: artworks)
            break
        case .distance:
            sortUsed = .distance
            if coordinate == nil {
                sections = sectionsByDistance(artworks: artworks, coordinateFrom: CLLocation(latitude: 0, longitude: 0))
            }
            else {
                sections = sectionsByDistance(artworks: artworks, coordinateFrom: coordinate!)
            }
            break
        }
    }
    
    
    //MARK: - Private methods
    private func sectionsByTitle(artworks: [Artwork]) -> [Section] {
        
        let artworksSortedByTitle = artworks.sorted(by: sortByTitle)
        // The key is the name of the section. The value is an array of Nameable inside the section
        var artworksSections = [String: [Artwork]]()
        var sortedArtworksSections = [(key: String, value: [Artwork])]()
        
        // The lastSection used
        var lastSectionUsed = ""
        
        // Build the sections that we're gonna use for the alphabetical sort
        for artwork in artworksSortedByTitle {
            
            // Extract the first letter of the current Nameable. Ignore accent and uppercase this firstLetter
            let title : String
            if artwork.title == nil || artwork.title == "" {
                title = Strings.unknownTitle
            }
            else {
                title = artwork.title!
            }
            var firstLetter = title[0...0].folding(options: .diacriticInsensitive, locale: .current).uppercased()
            
            if Int(firstLetter) != nil {
                firstLetter = "#"
            }
            
            // If this firstLetter is different of the last section used, so append a new section and append this Nameable into it
            if firstLetter != lastSectionUsed {
                artworksSections.updateValue([artwork], forKey: firstLetter)
                lastSectionUsed = firstLetter
            }
                // Else just append the Nameable into the last section
            else if var arr = artworksSections[lastSectionUsed] {
                arr.append(artwork)
                artworksSections.updateValue(arr, forKey: lastSectionUsed)
            }
        }
        
        // Sort the sections because a dictionnary is not sorted
        sortedArtworksSections = artworksSections.sorted(by: { $0.0 < $1.0 })
        
        var sections = sortedArtworksSections.map({Section(name: $0.key, items: $0.value)})
        
        // Numbers after character "Z"
        if sections.contains(where: { return $0.name == "#" }) {
            sections.append(sections.remove(at: 0))
        }
        return sections
    }
    
    private func sortByTitle(_ left: Artwork, _ right: Artwork) -> Bool {
        var lTitle : String
        var rTitle : String
        
        if left.title == nil || left.title == "" {
            lTitle = Strings.unknownTitle
        }
        else {
            lTitle = left.title!
        }
        
        if right.title == nil || right.title == "" {
            rTitle = Strings.unknownTitle
        }
        else {
            rTitle = right.title!
        }
        
        return lTitle.uppercased() < rTitle.uppercased()
    }
    
    private func sectionsByDate(artworks: [Artwork]) -> [Section] {
        // The key is the name of the section. The value is an array of artworks
        let artworksSortedByDate = artworks.sorted(by: sortByDate)
        var artworksSections = [String: [Artwork]]()
        var sortedArtworksSections = [(key: String, value: [Artwork])]()
        // The lastSection used
        var lastSection = ""
        
        for artwork in artworksSortedByDate {
            
            // Extract the first letter of the current artwork. Ignore accent and uppercase this firstLetter
            let year : String
            
            if let date = artwork.date {
                year = date.toString(format: "yyyy")
            }
            else {
                year = Strings.unknownDate
            }
            
            // If this firstLetter is different of the last section used, so append a new section and append this artwork into it
            if year != lastSection {
                artworksSections.updateValue([artwork], forKey: year)
                lastSection = year
            }
                // Else just append the artwork into the last section
            else if var arr = artworksSections[lastSection] {
                arr.append(artwork)
                artworksSections.updateValue(arr, forKey: lastSection)
            }
        }
        
        // SORTING [SINCE A DICTIONARY IS AN UNSORTED LIST]
        sortedArtworksSections = artworksSections.sorted(by: { $0.0 < $1.0 })
        
        var sections = [Section]()
        
        // And append the new sections
        for (key, value) in sortedArtworksSections {
            sections.append(Section(name: key, items: value))
        }
        
        return sections
    }
    
    
    private func sortByDate(_ left: Artwork, _ right: Artwork) -> Bool {
        return (left.date ?? .distantPast) < (right.date ?? .distantPast)
    }
    
    private func sectionsByDistance(artworks: [Artwork], coordinateFrom: CLLocation) -> [Section] {
        
        struct Distance {
            let distance : CLLocationDistance
            let artwork : Artwork
            
            init(_ distance: CLLocationDistance, _ artwork: Artwork) {
                self.distance = distance
                self.artwork = artwork
            }
        }
        
        self.coordinateFrom = coordinateFrom
        
        // The key is the name of the section. The value is an array of artworks
        var artworksSections = [String: [Distance]]()
        var sortedArtworksSections = [(key: String, value: [Distance])]()
        
        for artwork in artworks {

            let keyDistance : String
            
            let distance = coordinateFrom.distance(from: CLLocation(latitude: artwork.address.coordinate.latitude, longitude: artwork.address.coordinate.longitude))
            
            if distance <= 100 {
                keyDistance = NSLocalizedString("less than 100 m", comment: "")
            }
            else if distance <= 1000 {
                keyDistance = NSLocalizedString("less than 1 km", comment: "")
            }
            else if distance <= 5000 {
                keyDistance = NSLocalizedString("less than 5 km", comment: "")
            }
            else if distance <= 10000 {
                keyDistance = NSLocalizedString("less than 10 km", comment: "")
            }
            else {
                keyDistance = NSLocalizedString("more than 10 km", comment: "")
            }
            
            
            if var artworksValue = artworksSections[keyDistance] {
                artworksValue.append(Distance(distance, artwork))
                artworksSections.updateValue(artworksValue, forKey: keyDistance)
            }
            else {
                artworksSections.updateValue([Distance(distance, artwork)], forKey: keyDistance)
            }
        }
        
        let keys = [NSLocalizedString("less than 100 m", comment: ""),
                    NSLocalizedString("less than 1 km", comment: ""),
                    NSLocalizedString("less than 5 km", comment: ""),
                    NSLocalizedString("less than 10 km", comment: ""),
                    NSLocalizedString("more than 10 km", comment: "")]
        
        sortedArtworksSections = artworksSections.map({key, value in (key, value.sorted(by: { $0.distance < $1.distance } ) )})
        
        var sections = [Section]()
        
        for keyDistance in keys {
            let section = sortedArtworksSections.first(where: { $0.key == keyDistance })
            if section != nil {
                sections.append(Section(name: keyDistance.capitalizingFirstLetter(), items : (section?.value.map({$0.artwork}))!))
            }
        }
        
        return sections
    }
    
    
}
