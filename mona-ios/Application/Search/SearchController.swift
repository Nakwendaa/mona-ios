//
//  SearchController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-05.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

final class SearchController: UISearchController {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init() {
        let storyboard = UIStoryboard(name: "Search", bundle: .main)
        let searchResultsNavigationController = storyboard.instantiateViewController(withIdentifier: "SearchResultsNavigationController") as! UINavigationController
        super.init(searchResultsController: searchResultsNavigationController)
        let searchResultsController = searchResultsNavigationController.viewControllers[0] as! SearchResultsController
        searchResultsController.searchController = self
        delegate = searchResultsController
        searchBar.delegate = searchResultsController
        searchResultsUpdater = searchResultsController
        searchBar.tintColor = .black
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
