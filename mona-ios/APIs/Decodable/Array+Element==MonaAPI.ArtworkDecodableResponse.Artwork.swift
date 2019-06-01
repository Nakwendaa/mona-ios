//
//  CodableArtwork.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreData

extension Array where Element == MonaAPI.ArtworkDecodableResponse.Artwork {
    
    func createOrUpdate(into context: NSManagedObjectContext) {
        
        let entityDescription = [
            "Artwork" : NSEntityDescription.entity(forEntityName: String(describing: Artwork.self), in: context)!,
            "District" : NSEntityDescription.entity(forEntityName: String(describing: District.self), in: context)!,
            "Artist" : NSEntityDescription.entity(forEntityName: String(describing: Artist.self), in: context)!,
            "Material" : NSEntityDescription.entity(forEntityName: String(describing: Material.self), in: context)!,
            "Technique" : NSEntityDescription.entity(forEntityName: String(describing: Technique.self), in: context)!,
            "Address" : NSEntityDescription.entity(forEntityName: String(describing: Address.self), in: context)!,
            "Coordinate" : NSEntityDescription.entity(forEntityName: String(describing: Coordinate.self), in: context)!,
            "Category" : NSEntityDescription.entity(forEntityName: String(describing: Category.self), in: context)!,
            "Subcategory" : NSEntityDescription.entity(forEntityName: String(describing: Subcategory.self), in: context)!,
            "LocalizedString" : NSEntityDescription.entity(forEntityName: String(describing: LocalizedString.self), in: context)!
        ]
        
        var artists = [Int16 : Artist]()
        var districts = [String : District]()
        var materials = [String : Material]()
        var techniques = [String : Technique]()
        var categories = [String : Category]()
        var subcategories = [ Category : [String : Subcategory]]()
        
        // In a first loop, find artists, districts, materials, techniques, categories and subcategories used.
        for codableArtwork in self {
            updateDistricts(from: codableArtwork, to: &districts, entityDescription: entityDescription["District"]!, insertInto: context)
            updateArtists(from: codableArtwork, to: &artists, entityDescription: entityDescription["Artist"]!, insertInto: context)
            updateMaterials(from: codableArtwork, to: &materials, entityMaterial: entityDescription["Material"]!, entityLocalized: entityDescription["LocalizedString"]!, insertInto: context)
            updateTechniques(from: codableArtwork, to: &techniques, entityTechnique: entityDescription["Technique"]!, entityLocalized: entityDescription["LocalizedString"]!, insertInto: context)
            let category = updateCategories(from: codableArtwork, to: &categories, entityCategory: entityDescription["Category"]!, entityLocalized: entityDescription["LocalizedString"]!, insertInto: context)
            updateSubcategories(from: codableArtwork, to: &subcategories, category: category, entitySubcategory: entityDescription["Subcategory"]!, entityLocalized: entityDescription["LocalizedString"]!, insertInto: context)
        }
        
        // Fetch current artworks from the store
        let fetchArtworkRequest : NSFetchRequest<Artwork> = Artwork.fetchRequest()
        do {
            let artworks = try context.fetch(fetchArtworkRequest).toDictionary{ $0.id }

            for (_, artwork) in artworks {
                context.delete(artwork.address)
                context.delete(artwork.district)
                artwork.district.removeFromArtworks(artwork)
                context.delete(artwork.category)
                artwork.category.removeFromArtworks(artwork)
                if let subcategory = artwork.subcategory {
                    context.delete(subcategory)
                    subcategory.removeFromArtworks(artwork)
                }
                artwork.artists.forEach({
                    context.delete($0)
                    $0.removeFromArtworks(artwork)
                })
                artwork.materials.forEach({
                    context.delete($0)
                    $0.removeFromArtworks(artwork)
                })
                artwork.techniques.forEach({
                    context.delete($0)
                    $0.removeFromArtworks(artwork)
                })
            }
            
            
            for codableArtwork in self {
                var artwork = artworks[codableArtwork.id]
                if artwork == nil {
                    artwork = Artwork(entity: entityDescription["Artwork"]!, insertInto: context)
                    setupId(from: codableArtwork, into: artwork!)
                }
                setupTitle(from: codableArtwork, into: artwork!)
                setupDate(from: codableArtwork, into: artwork!)
                setupDimensions(from: codableArtwork, into: artwork!)
                setupArtists(from: codableArtwork, into: artwork!, artists: artists)
                setupAddressDistrict(from: codableArtwork, into: artwork!, districts: districts, context: context)
                setupMaterials(from: codableArtwork, into: artwork!, materials: materials)
                setupTechniques(from: codableArtwork, into: artwork!, techniques: techniques)
                if let category = setupCategory(from: codableArtwork, into: artwork!, categories: categories) {
                    if let subcategoriesOfCategory = subcategories[category] {
                        setupSubcategory(from: codableArtwork, into: artwork!, subcategories: subcategoriesOfCategory)
                    }
                }
            }
        }
        catch {
            log.error("Failed to fetch artwork: \(error)")
        }
    }
    
    private func setupId(from codableArtwork: Element, into artwork: Artwork) {
        artwork.id = codableArtwork.id
    }
    
    private func setupTitle(from codableArtwork: Element, into artwork: Artwork) {
        artwork.title = codableArtwork.title
    }
    
    private func setupDate(from codableArtwork: Element, into artwork: Artwork) {
        artwork.date = codableArtwork.date
    }
    
    private func setupDimensions(from codableArtwork: Element, into artwork: Artwork) {
        if codableArtwork.dimensions != nil {
            if !codableArtwork.dimensions!.isEmpty {
                let dimensions = codableArtwork.dimensions!.joined(separator: " x ")
                artwork.dimensions = dimensions.replacingOccurences(target: "x cm", withString: "cm")
            }
            else {
                artwork.dimensions = nil
            }
        }
        else {
            artwork.dimensions = nil
        }
    }
    
    private func setupArtists(from codableArtwork: Element, into artwork: Artwork, artists : [Int16 : Artist]) {
        if let codableArtists = codableArtwork.artists, !codableArtists.isEmpty {
            for codableArtist in codableArtists {
                if let artist = artists[codableArtist.id] {
                    artwork.addToArtists(artist)
                }
                else if let artist = artists[-1]{
                    artwork.addToArtists(artist)
                }
            }
        }
    }
    
    private func setupMaterials(from codableArtwork: Element, into artwork: Artwork, materials : [String : Material]) {
        if let codableMaterials = codableArtwork.materials, !codableMaterials.isEmpty {
            for codableMaterial in codableMaterials {
                if let frenchName = codableMaterial.fr,
                    let material = materials["fr_" + frenchName] {
                    artwork.addToMaterials(material)
                }
                else if let englishName = codableMaterial.en,
                    let material = materials["en_" + englishName] {
                    artwork.addToMaterials(material)
                }
            }
        }
    }
    
    private func setupTechniques(from codableArtwork: Element, into artwork: Artwork, techniques : [String : Technique]) {
        if let codableTechniques = codableArtwork.techniques, !codableTechniques.isEmpty {
            for codableTechnique in codableTechniques {
                if let frenchName = codableTechnique.fr,
                    let technique = techniques["fr_" + frenchName] {
                    artwork.addToTechniques(technique)
                }
                else if let englishName = codableTechnique.en,
                    let technique = techniques["en_" + englishName] {
                    artwork.addToTechniques(technique)
                }
            }
        }
    }
    
    private func setupCategory(from codableArtwork: Element, into artwork: Artwork, categories : [String : Category]) -> Category? {
        if  let codableCategory = codableArtwork.category {
            if  let frenchName = codableCategory.fr,
                let category = categories["fr_" + frenchName] {
                artwork.category = category
                return category
            }
            else if let englishName = codableCategory.en,
                let category = categories["en_" + englishName] {
                artwork.category = category
                return category
            }
        }
        return nil
    }
    
    private func setupSubcategory(from codableArtwork: Element, into artwork: Artwork, subcategories : [String : Subcategory]) {
        if  let codableSubcategory = codableArtwork.subcategory {
            if  let frenchName = codableSubcategory.fr,
                let subcategory = subcategories["fr_" + frenchName] {
                artwork.subcategory = subcategory
            }
            else if let englishName = codableSubcategory.en,
                let subcategory = subcategories["en_" + englishName] {
                artwork.subcategory = subcategory
            }
        }
    }
    
    private func setupAddressDistrict(from codableArtwork: Element, into artwork: Artwork, districts: [String : District], context: NSManagedObjectContext) {
        
        if  let districtName = codableArtwork.district,
            let district = districts[districtName] {
            artwork.district = district
        }
        
        
        let addressEntityDescription = NSEntityDescription.entity(forEntityName: String(describing: Address.self), in: context)!
        let address = Address(entity: addressEntityDescription, insertInto: context)
        address.district = artwork.district
        artwork.address = address
        
        if  let codableCoordinate = codableArtwork.coordinate,
            let latitude = codableCoordinate.latitude,
            let longitude = codableCoordinate.longitude {
            let coordinateEntityDescription = NSEntityDescription.entity(forEntityName: String(describing: Coordinate.self), in: context)!
            artwork.address.coordinate = Coordinate(entity: coordinateEntityDescription, insertInto: context)
            artwork.address.coordinate.latitude = latitude
            artwork.address.coordinate.longitude = longitude
        }
        
    }
    
    
    private func updateArtists(from codableArtwork: Element, to artists : inout [Int16 : Artist], entityDescription: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        if let codableArtists = codableArtwork.artists {
            if !codableArtists.isEmpty {
                for codableArtist in codableArtists {
                    if artists[codableArtist.id] == nil {
                        if codableArtist.name == "" || codableArtist.name == "Auteur Inconnu" {
                            if artists[-1] == nil {
                                let artist = Artist(entity: entityDescription, insertInto: context)
                                artist.id = -1
                                artist.name = nil
                                artist.isCollectiveName = false
                                artists.updateValue(artist, forKey: -1)
                            }
                        }
                        else {
                            let artist = Artist(entity: entityDescription, insertInto: context)
                            artist.id = codableArtist.id
                            artist.name = codableArtist.name.removeLeadingAndTrailingSpaces()
                            artist.isCollectiveName = codableArtist.isCollectiveName
                            artists.updateValue(artist, forKey: codableArtist.id)
                        }
                    }
                }
            }
        }
    }
    
    private func updateDistricts(from codableArtwork: Element, to districts : inout [String : District], entityDescription: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        if let districtName = codableArtwork.district {
            if districts[districtName] == nil {
                let district = District(entity: entityDescription, insertInto: context)
                district.name = districtName
                districts.updateValue(district, forKey: districtName)
            }
        }
    }
    
    private func updateMaterials(from codableArtwork: Element, to materials : inout [String : Material], entityMaterial: NSEntityDescription, entityLocalized: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        if let codableMaterials = codableArtwork.materials {
            if !codableMaterials.isEmpty {
                for codableMaterial in codableMaterials {
                    // If there is a french name but no english name for a material
                    if codableMaterial.fr != nil && (codableMaterial.en == nil || codableMaterial.en == "")  {
                        // If this french name doesn't exist in materials dict
                        if materials["fr_" + codableMaterial.fr!] == nil {
                            // Add a new material at this french key
                            let material = Material(entity: entityMaterial, insertInto: context)
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .fr
                            localizedName.localizedString = codableMaterial.fr!
                            material.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = material
                            materials.updateValue(material, forKey: "fr_" + codableMaterial.fr!)
                        }
                        // Else do nothing because this material has already been inserted in the materials dict
                    }
                        // If there is an english name but no french name for a material
                    else if codableMaterial.en != nil && (codableMaterial.fr == nil || codableMaterial.fr == "") {
                        // If this english name doesn't exist in materials dict
                        if materials["en_" + codableMaterial.en!] == nil {
                            // Add a new material at this english key
                            let material = Material(entity: entityMaterial, insertInto: context)
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .en
                            localizedName.localizedString = codableMaterial.en!
                            material.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = material
                            materials.updateValue(material, forKey: "en_" + codableMaterial.en!)
                        }
                        // Else do nothing because this material has already been inserted in the materials dict
                    }
                        // Else if there is an english name AND a french name for a material
                    else if codableMaterial.en != nil && codableMaterial.fr != nil {
                        // If this french name exists in materials dict, but no english name
                        if let material = materials["fr_" + codableMaterial.fr!], materials["en_" + codableMaterial.en!] == nil {
                            // Add localized english name for this material and update english name key in dictionary
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .en
                            localizedName.localizedString = codableMaterial.en!
                            material.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = material
                            materials.updateValue(material, forKey: "en_" + codableMaterial.en!)
                        }
                        // If this english name exists in materials dict, but no french name
                        if let material = materials["en_" + codableMaterial.en!], materials["fr_" + codableMaterial.fr!] == nil {
                            // Add localized english name for this material and update english name key in dictionary
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .fr
                            localizedName.localizedString = codableMaterial.fr!
                            material.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = material
                            materials.updateValue(material, forKey: "fr_" + codableMaterial.fr!)
                        }
                        else if materials["en_" + codableMaterial.en!] == nil, materials["fr_" + codableMaterial.fr!] == nil {
                            let material = Material(entity: entityMaterial, insertInto: context)
                            let localizedEnglishName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedEnglishName.language = .en
                            localizedEnglishName.localizedString = codableMaterial.en!
                            localizedEnglishName.localizableEntity = material
                            material.addToLocalizedNames(localizedEnglishName)
                            let englishKey = "en_" + codableMaterial.en!
                            materials.updateValue(material, forKey: englishKey)
                            let localizedFrenchName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedFrenchName.language = .fr
                            localizedFrenchName.localizedString = codableMaterial.fr!
                            localizedFrenchName.localizableEntity = material
                            material.addToLocalizedNames(localizedFrenchName)
                            let frenchKey = "fr_" + codableMaterial.fr!
                            materials.updateValue(material, forKey: frenchKey)
                        }
                    }
                }
            }
        }
    }
    
    private func updateTechniques(from codableArtwork: Element, to techniques : inout [String : Technique], entityTechnique: NSEntityDescription, entityLocalized: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        if let codableTechniques = codableArtwork.techniques {
            if !codableTechniques.isEmpty {
                for codableTechnique in codableTechniques {
                    // If there is a french name but no english name for a material
                    if codableTechnique.fr != nil && (codableTechnique.en == nil || codableTechnique.en == "") {
                        // If this french name doesn't exist in materials dict
                        if techniques["fr_" + codableTechnique.fr!] == nil {
                            // Add a new material at this french key
                            let technique = Technique(entity: entityTechnique, insertInto: context)
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .fr
                            localizedName.localizedString = codableTechnique.fr!
                            technique.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = technique
                            techniques.updateValue(technique, forKey: "fr_" + codableTechnique.fr!)
                        }
                        // Else do nothing because this material has already been inserted in the materials dict
                    }
                        // If there is an english name but no french name for a material
                    else if codableTechnique.en != nil && (codableTechnique.fr == nil || codableTechnique.fr == "") {
                        // If this english name doesn't exist in materials dict
                        if techniques["en_" + codableTechnique.en!] == nil {
                            // Add a new material at this english key
                            let technique = Technique(entity: entityTechnique, insertInto: context)
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .en
                            localizedName.localizedString = codableTechnique.en!
                            technique.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = technique
                            techniques.updateValue(technique, forKey: "en_" + codableTechnique.en!)
                        }
                        // Else do nothing because this material has already been inserted in the materials dict
                    }
                        // Else if there is an english name AND a french name for a material
                    else if codableTechnique.en != nil && codableTechnique.fr != nil {
                        // If this french name exists in materials dict, but no english name
                        if let technique = techniques["fr_" + codableTechnique.fr!], techniques["en_" + codableTechnique.en!] == nil {
                            // Add localized english name for this material and update english name key in dictionary
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .en
                            localizedName.localizedString = codableTechnique.en!
                            technique.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = technique
                            techniques.updateValue(technique, forKey: "en_" + codableTechnique.en!)
                        }
                        // If this english name exists in materials dict, but no french name
                        if let technique = techniques["en_" + codableTechnique.en!], techniques["fr_" + codableTechnique.fr!] == nil {
                            // Add localized english name for this material and update english name key in dictionary
                            let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedName.language = .fr
                            localizedName.localizedString = codableTechnique.fr!
                            technique.addToLocalizedNames(localizedName)
                            localizedName.localizableEntity = technique
                            techniques.updateValue(technique, forKey: "fr_" + codableTechnique.fr!)
                        }
                        else if techniques["en_" + codableTechnique.en!] == nil, techniques["fr_" + codableTechnique.fr!] == nil {
                            let technique = Technique(entity: entityTechnique, insertInto: context)
                            let localizedEnglishName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedEnglishName.language = .en
                            localizedEnglishName.localizedString = codableTechnique.en!
                            localizedEnglishName.localizableEntity = technique
                            technique.addToLocalizedNames(localizedEnglishName)
                            techniques.updateValue(technique, forKey: "en_" + codableTechnique.en!)
                            let localizedFrenchName = LocalizedString(entity: entityLocalized, insertInto: context)
                            localizedFrenchName.language = .fr
                            localizedFrenchName.localizedString = codableTechnique.fr!
                            localizedFrenchName.localizableEntity = technique
                            technique.addToLocalizedNames(localizedFrenchName)
                            techniques.updateValue(technique, forKey: "fr_" + codableTechnique.fr!)
                        }
                    }
                }
            }
        }
    }
    
    private func updateCategories(from codableArtwork: Element, to categories : inout [String : Category], entityCategory: NSEntityDescription, entityLocalized: NSEntityDescription, insertInto context: NSManagedObjectContext) -> Category? {
        // Ajouter une catégorie
        var category : Category?
        // Category
        if let codableCategory = codableArtwork.category {
            // If there is a french name but no english name for a material
            if codableCategory.fr != nil && codableCategory.en == nil {
                // If this french name doesn't exist in materials dict
                if categories["fr_" + codableCategory.fr!] == nil {
                    // Add a new material at this french key
                    category = Category(entity: entityCategory, insertInto: context)
                    let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                    localizedName.language = .fr
                    localizedName.localizedString = codableCategory.fr!
                    category!.addToLocalizedNames(localizedName)
                    localizedName.localizableEntity = category!
                    categories.updateValue(category!, forKey: "fr_" + codableCategory.fr!)
                }
                // Else do nothing because this material has already been inserted in the materials dict
            }
                // If there is an english name but no french name for a material
            else if codableCategory.en != nil && codableCategory.fr == nil {
                // If this english name doesn't exist in materials dict
                if categories["en_" + codableCategory.en!] == nil {
                    // Add a new material at this english key
                    category = Category(entity: entityCategory, insertInto: context)
                    let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                    localizedName.language = .en
                    localizedName.localizedString = codableCategory.en!
                    category!.addToLocalizedNames(localizedName)
                    localizedName.localizableEntity = category!
                    categories.updateValue(category!, forKey: "en_" + codableCategory.en!)
                }
                // Else do nothing because this material has already been inserted in the materials dict
            }
                // Else if there is an english name AND a french name for a material
            else if codableCategory.en != nil && codableCategory.fr != nil {
                // If this french name exists in materials dict, but no english name
                if let tempCategory = categories["fr_" + codableCategory.fr!], categories["en_" + codableCategory.en!] == nil {
                    // Add localized english name for this material and update english name key in dictionary
                    let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                    localizedName.language = .en
                    localizedName.localizedString = codableCategory.en!
                    tempCategory.addToLocalizedNames(localizedName)
                    localizedName.localizableEntity = tempCategory
                    categories.updateValue(tempCategory, forKey: "en_" + codableCategory.en!)
                    category = tempCategory
                }
                // If this english name exists in materials dict, but no french name
                if let tempCategory = categories["en_" + codableCategory.en!], categories["fr_" + codableCategory.fr!] == nil {
                    // Add localized english name for this material and update english name key in dictionary
                    let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                    localizedName.language = .fr
                    localizedName.localizedString = codableCategory.fr!
                    tempCategory.addToLocalizedNames(localizedName)
                    localizedName.localizableEntity = tempCategory
                    categories.updateValue(tempCategory, forKey: "fr_" + codableCategory.fr!)
                    category = tempCategory
                }
                else if categories["en_" + codableCategory.en!] == nil, categories["fr_" + codableCategory.fr!] == nil {
                    category = Category(entity: entityCategory, insertInto: context)
                    let localizedEnglishName = LocalizedString(entity: entityLocalized, insertInto: context)
                    localizedEnglishName.language = .en
                    localizedEnglishName.localizedString = codableCategory.en!
                    localizedEnglishName.localizableEntity = category!
                    category!.addToLocalizedNames(localizedEnglishName)
                    categories.updateValue(category!, forKey: "en_" + codableCategory.en!)
                    let localizedFrenchName = LocalizedString(entity: entityLocalized, insertInto: context)
                    localizedFrenchName.language = .fr
                    localizedFrenchName.localizedString = codableCategory.fr!
                    localizedFrenchName.localizableEntity = category!
                    category!.addToLocalizedNames(localizedFrenchName)
                    categories.updateValue(category!, forKey: "fr_" + codableCategory.fr!)
                }
                else {
                    category = categories["en_" + codableCategory.en!]!
                }
            }
        }
        return category
    }
    
    private func updateSubcategories(from codableArtwork: Element, to subcategories : inout [ Category : [String : Subcategory]], category: Category?, entitySubcategory: NSEntityDescription, entityLocalized: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        if category != nil {
            if let codableSubcategory = codableArtwork.subcategory {
                // If there is a french name but no english name for a subcategory
                if codableSubcategory.fr != nil && codableSubcategory.en == nil {
                    var subcategoriesOfCategory = subcategories[category!]
                    let frenchKey = "fr_" + codableSubcategory.fr!
                    // Si pas de sous-catégories pour une catégorie donnée OU pas de sous-catégories correpsondantes à un french name pour une catégorie donnée
                    if subcategoriesOfCategory == nil || subcategoriesOfCategory![frenchKey] == nil {
                        // Ajouter cette sous-catégorie à la catégorie avec un nom français
                        let subcategory = Subcategory(entity: entitySubcategory, insertInto: context)
                        let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        localizedName.language = .fr
                        localizedName.localizedString = codableSubcategory.fr!
                        subcategory.addToLocalizedNames(localizedName)
                        localizedName.localizableEntity = subcategory
                        // Si pas de sous-catégories encore pour cette catégories
                        if subcategoriesOfCategory == nil {
                            subcategories.updateValue([
                                "fr_" + codableSubcategory.fr! : subcategory
                                ], forKey: category!)
                        }
                            // Sinon il existe déjà des sous catégories
                        else {
                            subcategoriesOfCategory!.updateValue(subcategory, forKey: "fr_" + codableSubcategory.fr!)
                            subcategories.updateValue(subcategoriesOfCategory!, forKey: category!)
                        }
                        category!.addToSubcategories(subcategory)
                    }
                    // Else la sous-catégorie existe déjà. Donc rien à faire
                }
                    // If there is an english name but no french name for a material
                else if codableSubcategory.en != nil && codableSubcategory.fr == nil {
                    var subcategoriesOfCategory = subcategories[category!]
                    let englishKey = "en_" + codableSubcategory.en!
                    // Si pas de sous-catégories pour une catégorie donnée OU pas de sous-catégories correpsondantes à un french name pour une catégorie donnée
                    if subcategoriesOfCategory == nil || subcategoriesOfCategory![englishKey] == nil {
                        // Ajouter cette sous-catégorie à la catégorie avec un nom français
                        let subcategory = Subcategory(entity: entitySubcategory, insertInto: context)
                        let localizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        localizedName.language = .en
                        localizedName.localizedString = codableSubcategory.en!
                        subcategory.addToLocalizedNames(localizedName)
                        localizedName.localizableEntity = subcategory
                        // Si pas de sous-catégories encore pour cette catégorie
                        if subcategoriesOfCategory == nil {
                            subcategories.updateValue([
                                "en_" + codableSubcategory.en! : subcategory
                                ], forKey: category!)
                        }
                            // Sinon il existe déjà des sous catégories
                        else {
                            subcategoriesOfCategory!.updateValue(subcategory, forKey: "en_" + codableSubcategory.en!)
                            subcategories.updateValue(subcategoriesOfCategory!, forKey: category!)
                        }
                        category!.addToSubcategories(subcategory)
                    }
                }
                    // Else if there is an english name AND a french name for a material
                else if codableSubcategory.en != nil && codableSubcategory.fr != nil {
                    var subcategoriesOfCategory = subcategories[category!]
                    let englishKey = "en_" + codableSubcategory.en!
                    let frenchKey = "fr_" + codableSubcategory.fr!
                    
                    // If there is no subcategory assigned to the category decoded previously
                    if subcategoriesOfCategory == nil {
                        // Create a subcategory into the context
                        let subcategory = Subcategory(entity: entitySubcategory, insertInto: context)
                        // Build a an english localized string for the subcategory
                        let englishLocalizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        englishLocalizedName.language = .en
                        englishLocalizedName.localizedString = codableSubcategory.en!
                        // Assigned localized string built to the subcategory
                        subcategory.addToLocalizedNames(englishLocalizedName)
                        englishLocalizedName.localizableEntity = subcategory
                        // Build a french localized string for the subcategory
                        let frenchLocalizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        frenchLocalizedName.language = .fr
                        frenchLocalizedName.localizedString = codableSubcategory.fr!
                        // Assigned localized string built to the subcategory
                        subcategory.addToLocalizedNames(frenchLocalizedName)
                        frenchLocalizedName.localizableEntity = subcategory
                        
                        // Build
                        subcategories.updateValue([
                            "en_" + codableSubcategory.en! : subcategory,
                            "fr_" + codableSubcategory.fr! : subcategory
                            ], forKey: category!)
                        category!.addToSubcategories(subcategory)
                    }
                    else if subcategoriesOfCategory![englishKey] == nil &&  subcategoriesOfCategory![frenchKey] == nil {
                        // Create a subcategory into the context
                        let subcategory = Subcategory(entity: entitySubcategory, insertInto: context)
                        // Build a an english localized string for the subcategory
                        let englishLocalizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        englishLocalizedName.language = .en
                        englishLocalizedName.localizedString = codableSubcategory.en!
                        // Assigned localized string built to the subcategory
                        subcategory.addToLocalizedNames(englishLocalizedName)
                        englishLocalizedName.localizableEntity = subcategory
                        // Build a french localized string for the subcategory
                        let frenchLocalizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        frenchLocalizedName.language = .fr
                        frenchLocalizedName.localizedString = codableSubcategory.fr!
                        // Assigned localized string built to the subcategory
                        subcategory.addToLocalizedNames(frenchLocalizedName)
                        frenchLocalizedName.localizableEntity = subcategory
                        
                        subcategoriesOfCategory!.updateValue(subcategory, forKey: "en_" + codableSubcategory.en!)
                        subcategoriesOfCategory!.updateValue(subcategory, forKey: "fr_" + codableSubcategory.fr!)
                        subcategories.updateValue(subcategoriesOfCategory!, forKey: category!)
                        category!.addToSubcategories(subcategory)
                    }
                    else if subcategoriesOfCategory![frenchKey] != nil &&  subcategoriesOfCategory![englishKey] == nil {
                        let subcategory = subcategoriesOfCategory![frenchKey]!
                        // Build a an english localized string for the subcategory
                        let englishLocalizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        englishLocalizedName.language = .en
                        englishLocalizedName.localizedString = codableSubcategory.en!
                        // Assigned localized string built to the subcategory
                        subcategory.addToLocalizedNames(englishLocalizedName)
                        englishLocalizedName.localizableEntity = subcategory
                        subcategoriesOfCategory!.updateValue(subcategory, forKey: "en_" + codableSubcategory.en!)
                        subcategories.updateValue(subcategoriesOfCategory!, forKey: category!)
                        category!.addToSubcategories(subcategory)
                    }
                    else if subcategoriesOfCategory![englishKey] != nil &&  subcategoriesOfCategory![frenchKey] == nil {
                        let subcategory = subcategoriesOfCategory![englishKey]!
                        // Build a an english localized string for the subcategory
                        let frenchLocalizedName = LocalizedString(entity: entityLocalized, insertInto: context)
                        frenchLocalizedName.language = .fr
                        frenchLocalizedName.localizedString = codableSubcategory.fr!
                        // Assigned localized string built to the subcategory
                        subcategory.addToLocalizedNames(frenchLocalizedName)
                        frenchLocalizedName.localizableEntity = subcategory
                        subcategoriesOfCategory!.updateValue(subcategory, forKey: "fr_" + codableSubcategory.fr!)
                        subcategories.updateValue(subcategoriesOfCategory!, forKey: category!)
                        category!.addToSubcategories(subcategory)
                    }
                    else {
                        // Ne rien faire, car on a trouvé pour les deux que la subcat existe déjà
                    }
                }
            }
        }
    }
    
}
