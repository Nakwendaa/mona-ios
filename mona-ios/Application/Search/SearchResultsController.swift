//
//  SearchResultsController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-04.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class SearchResultsController: UIViewController, UISearchControllerDelegate {
    
    //MARK: - Types
    struct Segues {
        static let showArtworkDetailsViewController = "showArtworkDetailsViewController"
        static let showArtworksTableViewController = "showArtworksTableViewController"
    }
    
    struct Strings {
        private static let tableName = "SearchResultsController"
        static let artists = NSLocalizedString("artists", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let artworks = NSLocalizedString("artworks", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let categories = NSLocalizedString("categories", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let districts = NSLocalizedString("districts", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let materials = NSLocalizedString("materials", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let subcategories = NSLocalizedString("subcategories", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let techniques = NSLocalizedString("techniques", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    }
    
    //MARK: - Properties
    weak var searchController : UISearchController?
    var searchTerms : String = ""
    var searchDataSource = SearchResultsDataSource()
    var didViewLoad = false
    
    //MARK: - UI Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = searchDataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchController?.searchBar.isHidden = false
        if didViewLoad {
            tableView.reloadData()
        }
        didViewLoad = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case Segues.showArtworksTableViewController:
            let destination = segue.destination as! ArtworksTableViewController
            if let cell = sender as? GeneralTableViewCell {
                destination.title = cell.titleLabel.text
                destination.artworks = cell.artworks
            }
            else if let title = sender as? String, title == Strings.artworks {
                destination.title = title
                destination.artworks = searchDataSource.artworksFiltered
            }
            searchController?.searchBar.isHidden = true
            return
        case Segues.showArtworkDetailsViewController:
            let destination = segue.destination as! ArtworkDetailsViewController
            let cell = sender as! ArtworkTableViewCell
            destination.artwork = cell.artwork
            searchController?.searchBar.isHidden = true
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func showGeneralTableViewController(title: String) {
        
        searchController?.searchBar.isHidden = true
        
        func showGeneralTableViewController<T: ArtworksSettable & TextRepresentable>(title: String, items: [T]) {
            let generalTableViewController = GeneralTableViewController<T>(nibName: "GeneralTableViewController", bundle: .main)
            generalTableViewController.title = title
            generalTableViewController.items = items
            navigationController?.pushViewController(generalTableViewController, animated: true)
        }
        
        switch title {
        case Strings.artists:
            showGeneralTableViewController(title: title, items: searchDataSource.artistsFiltered)
        case Strings.categories:
            showGeneralTableViewController(title: title, items: searchDataSource.categoriesFiltered)
        case Strings.districts:
            showGeneralTableViewController(title: title, items: searchDataSource.districtsFiltered)
        case Strings.materials:
            showGeneralTableViewController(title: title, items: searchDataSource.materialsFiltered)
        case Strings.subcategories:
            showGeneralTableViewController(title: title, items: searchDataSource.subcategoriesFiltered)
        case Strings.techniques:
            showGeneralTableViewController(title: title, items: searchDataSource.techniquesFiltered)
        default:
            break
        }
    }
    
    @IBAction func tableViewTapped(_ sender: UITapGestureRecognizer) {
        searchController?.searchBar.endEditing(true)
    }
    
}

//MARK: - UITableViewDelegate
extension SearchResultsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? ArtworkTableViewCell {
            performSegue(withIdentifier: Segues.showArtworkDetailsViewController, sender: cell)
        }
        else if let cell = tableView.cellForRow(at: indexPath) as? GeneralTableViewCell {
            performSegue(withIdentifier: Segues.showArtworksTableViewController, sender: cell)
        }
    }
    
    // Add a UITapGestureRecognizer in order to make the section header of the tableView tappable
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let sectionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sectionTableViewTapped(_:)))
        view.addGestureRecognizer(sectionTapGestureRecognizer)
        
    }
    
    @objc func sectionTableViewTapped(_ sender: UITapGestureRecognizer) {
        
        guard let headerView = sender.view! as? UITableViewHeaderFooterView,
            let headerLabel = headerView.textLabel,
            let headerTitle = headerLabel.text?.lowercased(),
            headerTitle.contains(">") else {
                return
        }
        
        let sectionName = headerTitle.replacingOccurences(target: " >", withString: "").capitalizingFirstLetter()
        switch sectionName {
        case Strings.artworks:
            performSegue(withIdentifier: Segues.showArtworksTableViewController, sender: Strings.artworks)
        default:
            showGeneralTableViewController(title: sectionName)
        }
        searchController?.searchBar.endEditing(true)
    }
}

//MARK: - UISearchBarDelegate
extension SearchResultsController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async {
            self.searchTerms = searchText
            self.searchDataSource.filter(searchTerms: self.searchTerms)
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchTerms
    }
    
    /*
     
     func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
     guard let viewController = UIStoryboard(name: "Application", bundle: nil).instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController else { return }
     
     let navController = UINavigationController(rootViewController: viewController)
     searchController.present(navController, animated: true, completion: nil)
     }
     */
}

//MARK: - UISearchResultsUpdating
extension SearchResultsController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if tableView.numberOfSections == 0 {
            tableView.backgroundColor = .white
        }
        else {
            tableView.backgroundColor = UIColor.init(red: 211, green: 211, blue: 211, alpha: 1)
        }
    }
    
}

//MARK: - UIScrollViewDelegate
extension SearchResultsController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController?.searchBar.endEditing(true)
    }
}
