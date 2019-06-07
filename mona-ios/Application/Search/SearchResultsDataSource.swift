//
//  SearchResultsDataSource.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-04.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class SearchResultsDataSource : NSObject, UITableViewDataSource {
    
    struct Strings {
        private static let tableName = "SearchResultsDataSource"
        static let artists = NSLocalizedString("artists", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let artworks = NSLocalizedString("artworks", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let categories = NSLocalizedString("categories", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let districts = NSLocalizedString("districts", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let materials = NSLocalizedString("materials", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let subcategories = NSLocalizedString("subcategories", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let techniques = NSLocalizedString("techniques", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    
    struct Section {
        var name : String
        var items : [Namable]
    }
    
    var sections = [Section]()
    var artistsFiltered = [Artist]()
    var artworksFiltered = [Artwork]()
    var categoriesFiltered = [Category]()
    var districtsFiltered = [District]()
    var materialsFiltered = [Material]()
    var subcategoriesFiltered = [Subcategory]()
    var techniquesFiltered = [Technique]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if sections[section].name == Strings.artists && artistsFiltered.count > 3
            || sections[section].name == Strings.artworks && artworksFiltered.count > 3
            || sections[section].name == Strings.categories && categoriesFiltered.count > 3
            || sections[section].name == Strings.districts && districtsFiltered.count > 3
            || sections[section].name == Strings.materials && materialsFiltered.count > 3
            || sections[section].name == Strings.subcategories && subcategoriesFiltered.count > 3
            || sections[section].name == Strings.techniques && techniquesFiltered.count > 3 {
            return sections[section].name.capitalizingFirstLetter() + " >"
        }
        else {
            return sections[section].name.capitalizingFirstLetter()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cast test
        if sections[indexPath.section].name == Strings.artworks {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtworkTableViewCell.reuseIdentifier, for: indexPath) as? ArtworkTableViewCell  else {
                fatalError("The dequeued cell is not an instance of ArtworkTableViewCell.")
            }
            
            // Fetches the appropriate artwork for the data source layout.
            let artwork = artworksFiltered[indexPath.row]
            cell.titleLabel.text = artwork.title
            cell.subtitleLabel.text = artwork.address.district.nameNamable
            cell.artwork = artwork
            guard let photos = artwork.photos, let photo = photos.firstObject as? Photo else {
                return cell
            }
            cell.photoImageView.image = UIImage(named: photo.localIdentifier)
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GeneralTableViewCell.reuseIdentifier, for: indexPath) as? GeneralTableViewCell  else {
                fatalError("The dequeued cell is not an instance of ArtworkTableViewCell.")
            }
            
            // Fetches the appropriate artwork for the data source layout.
            
            if sections[indexPath.section].name == Strings.artists {
                let artist = artistsFiltered[indexPath.row]
                cell.artworks = Array(artist.artworks)
                cell.titleLabel.text = artist.nameNamable
                cell.subtitleLabel.text = "\(cell.artworks.count) " + Strings.artworks.lowercased()
            }
            else if sections[indexPath.section].name == Strings.categories {
                let category = categoriesFiltered[indexPath.row]
                cell.artworks = Array(category.artworks)
                cell.titleLabel.text = category.nameNamable
                cell.subtitleLabel.text = "\(cell.artworks.count) " + Strings.artworks.lowercased()
            }
            else if sections[indexPath.section].name == Strings.districts {
                let district = districtsFiltered[indexPath.row]
                cell.artworks = Array(district.artworks)
                cell.titleLabel.text = district.nameNamable
                cell.subtitleLabel.text = "\(cell.artworks.count) " + Strings.artworks.lowercased()
            }
            else if sections[indexPath.section].name == Strings.materials {
                let material = materialsFiltered[indexPath.row]
                cell.artworks = Array(material.artworks)
                cell.titleLabel.text = material.nameNamable
                cell.subtitleLabel.text = "\(cell.artworks.count) " + Strings.artworks.lowercased()
            }
            else if sections[indexPath.section].name == Strings.subcategories {
                let subcategory = subcategoriesFiltered[indexPath.row]
                cell.artworks = Array(subcategory.artworks)
                cell.titleLabel.text = subcategory.nameNamable
                cell.subtitleLabel.text = "\(cell.artworks.count) " + Strings.artworks.lowercased().lowercased()
            }
            else if sections[indexPath.section].name == Strings.techniques {
                let technique = techniquesFiltered[indexPath.row]
                cell.artworks = Array(technique.artworks)
                cell.titleLabel.text = technique.nameNamable
                cell.subtitleLabel.text = "\(cell.artworks.count) " + Strings.artworks.lowercased()
            }
            
            return cell
        }
    }
    
    func filter(searchTerms : String) {
        
        var searchString = searchTerms.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        searchString = searchString.replacingOccurences(target: "^ *| *$", withString: "")
        
        sections = [Section]()
        
        // Artists
        artistsFiltered = AppData.artists.filter { artist in
            var artistName = artist.nameNamable.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            artistName = artistName.replacingOccurences(target: "-", withString: " ")
            return artistName.range(of: searchString) != nil
        }
        artistsFiltered.sort { $0.nameNamable < $1.nameNamable }
        
        var artists = [Artist]()
        
        for i in 0..<min(artistsFiltered.count,3) {
            artists.append(artistsFiltered[i])
        }
        
        if artists.count != 0 {
            sections.append(Section(name: Strings.artists, items: artists))
        }
        
        // Artworks
        artworksFiltered = AppData.artworks.filter { artwork in
            var artworkName = artwork.nameNamable.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            artworkName = artworkName.replacingOccurences(target: "-", withString: " ")
            return artworkName.range(of: searchString) != nil
        }
        
        artworksFiltered = artworksFiltered.sorted {
            $0.nameNamable < $1.nameNamable
        }
        
        var artworks = [Artwork]()
        
        for i in 0..<min(artworksFiltered.count,3) {
            artworks.append(artworksFiltered[i])
        }
        
        if artworks.count != 0 {
            sections.append(Section(name: Strings.artworks, items: artworks))
        }
        
        // Categories
        categoriesFiltered = AppData.categories.filter { category in
            var categoryName = category.nameNamable.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            categoryName = categoryName.replacingOccurences(target: "-", withString: " ")
            return categoryName.range(of: searchString) != nil
        }
        
        categoriesFiltered = categoriesFiltered.sorted(by: {$0.nameNamable < $1.nameNamable })
        
        var categories = [Category]()
        
        for i in 0..<min(categoriesFiltered.count,3) {
            categories.append(categoriesFiltered[i])
        }
        
        if categories.count != 0 {
            sections.append(Section(name: Strings.categories, items: categories))
        }
        
        // Districts
        districtsFiltered = AppData.districts.filter { district in
            var districtName = district.nameNamable.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            districtName = districtName.replacingOccurences(target: "-", withString: " ")
            return districtName.range(of: searchString) != nil
        }
        districtsFiltered = districtsFiltered.sorted(by: {$0.nameNamable < $1.nameNamable })
        
        var districts = [District]()
        
        for i in 0..<min(districtsFiltered.count,3) {
            districts.append(districtsFiltered[i])
        }
        
        if districts.count != 0 {
            sections.append(Section(name: Strings.districts, items: districts))
        }
        
        // Materials
        materialsFiltered = AppData.materials.filter { material in
            var materialName = material.nameNamable.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            materialName = materialName.replacingOccurences(target: "-", withString: " ")
            return materialName.range(of: searchString) != nil
        }
        materialsFiltered = materialsFiltered.sorted(by: {$0.nameNamable < $1.nameNamable })
        
        var materials = [Material]()
        
        for i in 0..<min(materialsFiltered.count,3) {
            materials.append(materialsFiltered[i])
        }
        
        if materials.count != 0 {
            sections.append(Section(name: Strings.materials, items: materials))
        }
        
        // Subcategories
        subcategoriesFiltered = AppData.subcategories.filter { subcategory in
            var subcategoryName = subcategory.nameNamable.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            subcategoryName = subcategoryName.replacingOccurences(target: "-", withString: " ")
            return subcategoryName.range(of: searchString) != nil
        }
        subcategoriesFiltered = subcategoriesFiltered.sorted(by: {$0.nameNamable < $1.nameNamable })
        
        var subcategories = [Subcategory]()
        
        for i in 0..<min(subcategoriesFiltered.count,3) {
            subcategories.append(subcategoriesFiltered[i])
        }
        
        if subcategories.count != 0 {
            sections.append(Section(name: Strings.subcategories, items: subcategories))
        }
        
        // Techniques
        techniquesFiltered = AppData.techniques.filter { technique in
            var techniqueName = technique.nameNamable.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            techniqueName = techniqueName.replacingOccurences(target: "-", withString: " ")
            return techniqueName.range(of: searchString) != nil
        }
        techniquesFiltered = techniquesFiltered.sorted(by: {$0.nameNamable < $1.nameNamable })
        
        var techniques = [Technique]()
        
        for i in 0..<min(techniquesFiltered.count,3) {
            techniques.append(techniquesFiltered[i])
        }
        
        if techniques.count != 0 {
            sections.append(Section(name: Strings.techniques, items: techniques))
        }
        
    }
    
}

