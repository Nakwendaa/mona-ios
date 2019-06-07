//
//  SearchController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-05.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

final class SearchController: UISearchController {
    
    class func commonInit() -> SearchController {
        let storyboard = UIStoryboard(name: "Search", bundle: .main)
        let searchResultsNavigationController = storyboard.instantiateViewController(withIdentifier: "SearchResultsNavigationController") as! UINavigationController
        let searchResultsController = searchResultsNavigationController.viewControllers[0] as! SearchResultsController
        let searchController = SearchController(searchResultsController: searchResultsNavigationController)
        searchResultsController.searchController = searchController
        searchController.delegate = searchResultsController
        searchController.searchBar.delegate = searchResultsController
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.tintColor = .black
        return searchController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = .white
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .clear
        }
    }

}
