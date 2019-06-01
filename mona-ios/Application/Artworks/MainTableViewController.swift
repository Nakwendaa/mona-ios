//
//  MainTableViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2018-09-10.
//  Copyright © 2018 Lena Krause. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UIViewController, Contextualizable {
    
    //MARK: - Types
    struct Strings {
        private static let tableName = "MainTableViewController"
        static let artworksTrunc = NSLocalizedString("artworks-trunc", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let titles = NSLocalizedString("titles", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let artists = NSLocalizedString("artists", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let districts = NSLocalizedString("districts", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let categories = NSLocalizedString("categories", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let techniques = NSLocalizedString("techniques", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let materials = NSLocalizedString("materials", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let unknownDistrict = NSLocalizedString("unknown district", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    
    struct SeguesIdentifiers {
        static let showCategoryDistrictMainTableViewController = "showCategoryDistrictMainTableViewController"
        static let showSubcategories = "showSubcategories"
        static let showGeneralTableViewController = "showGeneralTableViewController"
        static let showArtworksTableViewController = "showArtworksTableViewController"
    }
    
    //MARK: - Properties
    var viewContext: NSManagedObjectContext?
    var tableViewCellCollection : [String] = [
        Strings.titles,
        Strings.artists,
        Strings.categories,
        Strings.districts,
        Strings.materials,
        Strings.techniques
    ]
    
    //MARK: - UI Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerViewLabel: UILabel!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let senderString = sender as? String else {
            return
        }
        
        // Pass context
        if var contextualizableViewController = segue.destination as? Contextualizable {
            contextualizableViewController.viewContext = viewContext
        }

        switch identifier {
        case SeguesIdentifiers.showCategoryDistrictMainTableViewController:
            prepareShowCategoryDistrictMainTableViewController(segue: segue, senderString: senderString)
        case SeguesIdentifiers.showSubcategories:
            prepareShowSubcategories(segue: segue, senderString: senderString)
            return
        case SeguesIdentifiers.showGeneralTableViewController:
            segue.destination.title = senderString
        case SeguesIdentifiers.showArtworksTableViewController:
            prepareShowArtworksTableViewController(segue: segue, senderString: senderString)
        default:
            return
        }
        
    }
    
    //MARK: - Private methods
    private func setupViewController () {
        if title == nil {
            title = Strings.artworksTrunc
        }
        setTransparentNavigationBar(tintColor: .black)
        
    }
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        headerViewLabel.text = title
    }
    
    private func prepareShowCategoryDistrictMainTableViewController(segue: UIStoryboardSegue, senderString: String) {
        let vc = segue.destination as! MainTableViewController
        // Get the viewContext
        guard let context = viewContext else {
            return
        }
        
        switch senderString {
        case Strings.categories:
            // Prepare
            let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
            do {
                let categories = try context.fetch(fetchRequest)
                vc.tableViewCellCollection = categories.map({$0.localizedName}).sorted()
                vc.title = Strings.categories
            }
            catch {
                log.error("Failing to fetch categories. Error: \(error)")
            }
            return
        case Strings.districts:
            let fetchRequest : NSFetchRequest<District> = District.fetchRequest()
            do {
                let districts = try context.fetch(fetchRequest)
                vc.tableViewCellCollection = districts.map({
                    $0.name
                }).sorted()
                vc.title = Strings.districts
            }
            catch {
                log.error("Failing to fetch districts. Error: \(error)")
            }
            return
        default:
            return
        }
    }
    
    private func prepareShowArtworksTableViewController(segue: UIStoryboardSegue, senderString: String) {
        guard let context = viewContext else {
            return
        }
        if let vc = segue.destination as? ArtworksTableViewController {
            if title == Strings.districts {
                let districtName = senderString
                vc.title = districtName
                let fetchDistrictRequest : NSFetchRequest<District> = District.fetchRequest()
                fetchDistrictRequest.predicate = NSPredicate(format: "name == %@", districtName)
                fetchDistrictRequest.fetchLimit = 1
                do {
                    let districts = try context.fetch(fetchDistrictRequest)
                    if let district = districts.first {
                        vc.artworksIds = district.artworks.map({$0.id})
                    }
                    else {
                        vc.artworksIds = [Int16]()
                    }
                }
                catch {
                    log.error("Failing to fetch district. Error: \(error)")
                }
            }
            else if title == Strings.categories {
                let categoryName = senderString
                //Show artworks of the category
                vc.title = categoryName
                let fetchCategoryRequest : NSFetchRequest<Category> = Category.fetchRequest()
                fetchCategoryRequest.predicate = NSPredicate(format: "%@ IN localizedNames.localizedString", categoryName)
                fetchCategoryRequest.fetchLimit = 1
                do {
                    let categories = try context.fetch(fetchCategoryRequest)
                    if let category = categories.first {
                        vc.artworksIds = category.artworks.map({$0.id})
                    }
                    else {
                        vc.artworksIds = [Int16]()
                    }
                }
                catch {
                    log.error("Failed to fetch category with name \"\(categoryName)\". Error: \(error).")
                }
            }
            else if title == Strings.artworksTrunc {
                vc.title = Strings.titles
            }
            else {
                //Show subcategories
                let subcategoryName = senderString
                vc.title = subcategoryName
                let fetchSubcategoryRequest : NSFetchRequest<Subcategory> = Subcategory.fetchRequest()
                fetchSubcategoryRequest.predicate = NSPredicate(format: "%@ IN localizedNames.localizedString", subcategoryName)
                fetchSubcategoryRequest.fetchLimit = 1
                do {
                    let subcategories = try context.fetch(fetchSubcategoryRequest)
                    if let subcategory = subcategories.first {
                        vc.artworksIds = subcategory.artworks.map({$0.id})
                    }
                    else {
                        vc.artworksIds = [Int16]()
                    }
                }
                catch {
                    log.error("Failing to fetch subcategory. Error: \(error)")
                }
            }
        }
    }
    
    private func prepareShowSubcategories(segue: UIStoryboardSegue, senderString: String) {
        guard let context = viewContext else {
            return
        }
        let categoryName = senderString
        if  let vc = segue.destination as? MainTableViewController,
            let fetchedCategory = Category.fetchRequest(name: categoryName, context: context),
            let subcategories = fetchedCategory.subcategories {
            vc.title = categoryName
            vc.tableViewCellCollection = subcategories.map({ $0.localizedName }).sorted()
        }
    }

}

//MARK: - UITableViewDataSource
extension MainTableViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewCellCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "MainTableViewCell"
        let mainTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! MainTableViewCell
        mainTableViewCell.label.text = tableViewCellCollection[indexPath.row]
        
        return mainTableViewCell
        
    }
    
}

// MARK: - UITableViewDelegate
extension MainTableViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch title {
        case Strings.artworksTrunc:
            switch tableViewCellCollection[indexPath.row] {
            case Strings.titles:
                return performSegue(withIdentifier: SeguesIdentifiers.showArtworksTableViewController, sender: Strings.titles)
            case Strings.artists:
                return performSegue(withIdentifier: SeguesIdentifiers.showGeneralTableViewController, sender: Strings.artists)
            case Strings.districts:
                return performSegue(withIdentifier: SeguesIdentifiers.showCategoryDistrictMainTableViewController, sender: Strings.districts)
            case Strings.categories:
                return performSegue(withIdentifier: SeguesIdentifiers.showCategoryDistrictMainTableViewController, sender: Strings.categories)
            case Strings.materials:
                return performSegue(withIdentifier: SeguesIdentifiers.showGeneralTableViewController, sender: Strings.materials)
            case Strings.techniques:
                return performSegue(withIdentifier: SeguesIdentifiers.showGeneralTableViewController, sender: Strings.techniques)
            default:
                return
            }
        case Strings.categories:
            guard let context = viewContext else {
                return
            }
            let categoryName = tableViewCellCollection[indexPath.row]
            if  let fetchedCategory = Category.fetchRequest(name: categoryName, context: context),
                fetchedCategory.subcategories != nil, !fetchedCategory.subcategories!.isEmpty{
                return performSegue(withIdentifier: SeguesIdentifiers.showSubcategories, sender: tableViewCellCollection[indexPath.row])
            }
            else {
                return performSegue(withIdentifier: SeguesIdentifiers.showArtworksTableViewController, sender: tableViewCellCollection[indexPath.row])
            }
        case Strings.districts:
            return performSegue(withIdentifier: SeguesIdentifiers.showArtworksTableViewController, sender: tableViewCellCollection[indexPath.row])
        default:
            return performSegue(withIdentifier: SeguesIdentifiers.showArtworksTableViewController, sender: tableViewCellCollection[indexPath.row])
        }
    }
}

