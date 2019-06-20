//
//  MainTableViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2018-09-10.
//  Copyright © 2018 Lena Krause. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: SearchViewController {
    
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
    
    struct Segues {
        static let showCategoryDistrictMainTableViewController = "showCategoryDistrictMainTableViewController"
        static let showSubcategories = "showSubcategories"
        static let showGeneralTableViewController = "showGeneralTableViewController"
        static let showArtworksTableViewController = "showArtworksTableViewController"
    }
    
    //MARK: - Properties
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
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case Segues.showArtworksTableViewController:
            let title = sender as! String
            let destination = segue.destination as! ArtworksTableViewController
            prepareShowArtworksTableViewController(sender: self.title!, title: title, destination: destination)
        case Segues.showGeneralTableViewController:
            break
        case Segues.showCategoryDistrictMainTableViewController:
            let title = sender as! String
            let destination = segue.destination as! MainTableViewController
            prepareShowCategoryDistrictMainTableViewController(title: title, destination: destination)
        case Segues.showSubcategories:
            let categoryName = sender as! String
            let destination = segue.destination as! MainTableViewController
            prepareShowSubcategories(categoryName: categoryName, destination: destination)
        default:
            break
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
        DispatchQueue.main.async {
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
        tableView.delegate = self
        headerViewLabel.text = title
    }
    
    private func showGeneralTableViewController<T: ArtworksSettable & TextRepresentable>(title: String, type: T.Type) {
        let destination = GeneralTableViewController<T>(nibName: "GeneralTableViewController", bundle: .main)
        destination.title = title
        DispatchQueue.main.async {
            if let generalTableVC = destination as? GeneralTableViewController<Artist> {
                generalTableVC.items = AppData.artists
            }
            else if let generalTableVC = destination as? GeneralTableViewController<Material> {
                generalTableVC.items = AppData.materials
            }
            else if let generalTableVC = destination as? GeneralTableViewController<Technique> {
                generalTableVC.items = AppData.techniques
            }
        }
        navigationController?.pushViewController(destination, animated: true)
    }
    
    private func prepareShowArtworksTableViewController(sender: String, title: String, destination: ArtworksTableViewController) {
        switch sender {
        case Strings.artworksTrunc:
            destination.title = Strings.titles
            DispatchQueue.main.async {
                destination.artworks = AppData.artworks
            }
            return
        case Strings.categories:
            let categoryName = title
            destination.title = categoryName
            guard let category = AppData.categories.first(where: { $0.text == categoryName }) else {
                return
            }
            destination.artworks = Array(category.artworks)
            return
        case Strings.districts:
            let districtName = title
            destination.title = districtName
            guard let district = AppData.districts.first(where: { $0.name == districtName }) else {
                return
            }
            destination.artworks = Array(district.artworks)
            return
        default:
            let subcategoryName = title
            destination.title = subcategoryName
            guard let subcategory = AppData.subcategories.first(where: { $0.text == subcategoryName }) else {
                return
            }
            destination.artworks = Array(subcategory.artworks)
            return
        }
    }
    
    private func prepareShowCategoryDistrictMainTableViewController(title: String, destination: MainTableViewController) {
        switch title {
        case Strings.categories:
            destination.title = Strings.categories
            DispatchQueue.main.async {
                destination.tableViewCellCollection = AppData.categories.map { $0.text }.sorted()
            }
            return
        case Strings.districts:
            destination.title = Strings.districts
            DispatchQueue.main.async {
                destination.tableViewCellCollection = AppData.districts.map { $0.name }.sorted()
            }
            return
        default:
            return
        }
    }
    
    private func prepareShowSubcategories(categoryName: String, destination: MainTableViewController) {
        guard let category = AppData.categories.first(where:{$0.text == categoryName}) else {
            log.error("Category with localized name \"\(categoryName)\" not found.")
            return
        }
        guard let subcategories = category.subcategories, !subcategories.isEmpty else {
            log.error("Category with localized name \"\(categoryName)\" has a empty subcategories' set.")
            return
        }
        destination.title = categoryName
        DispatchQueue.main.async {
            destination.tableViewCellCollection = subcategories.map{ $0.text }.sorted()
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
                performSegue(withIdentifier: Segues.showArtworksTableViewController, sender: Strings.titles)
            case Strings.artists:
                showGeneralTableViewController(title: Strings.artists, type: Artist.self)
            case Strings.districts:
                performSegue(withIdentifier: Segues.showCategoryDistrictMainTableViewController, sender: Strings.districts)
            case Strings.categories:
                return performSegue(withIdentifier: Segues.showCategoryDistrictMainTableViewController, sender: Strings.categories)
            case Strings.materials:
                showGeneralTableViewController(title: Strings.materials, type: Material.self)
            case Strings.techniques:
                showGeneralTableViewController(title: Strings.techniques, type: Technique.self)
            default:
                return
            }
        case Strings.categories:
            let categoryName = tableViewCellCollection[indexPath.row]
            guard let category = AppData.categories.first(where: { $0.text == categoryName}) else {
                return
            }
            if let subcategories = category.subcategories, !subcategories.isEmpty {
                return performSegue(withIdentifier: Segues.showSubcategories, sender: tableViewCellCollection[indexPath.row])
            }
            else {
                return performSegue(withIdentifier: Segues.showArtworksTableViewController, sender: tableViewCellCollection[indexPath.row])
            }
        case Strings.districts:
            return performSegue(withIdentifier: Segues.showArtworksTableViewController, sender: tableViewCellCollection[indexPath.row])
        default:
            return performSegue(withIdentifier: Segues.showArtworksTableViewController, sender: tableViewCellCollection[indexPath.row])
        }
    }
}

extension MainTableViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Show title if the user scrolled below the main tableHeaderView
        
        guard let heightTableHeaderView = tableView.tableHeaderView?.bounds.height else {
                return
        }
        
        let didTheUserScrolledBelowTableHeaderView = tableView.contentOffset.y >= heightTableHeaderView
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
