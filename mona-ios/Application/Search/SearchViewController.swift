//
//  SearchViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-06.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class SearchViewController : UIViewController, UITabBarControllerDelegate {
    
    var searchController : UISearchController?
    
    override func viewDidLoad() {
        
        guard let navigationController = navigationController,
            !(navigationController.viewControllers[0] is SearchResultsController) else {
                return
        }
        
        let searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(searchTapped))
        navigationItem.rightBarButtonItems = [searchBarButtonItem]
    }
    
    @objc func searchTapped() {
        tabBarController?.delegate = self
        searchController = SearchController.commonInit()
        definesPresentationContext = true
        present(searchController!, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard   let navigationController = viewController as? UINavigationController,
                let searchController = searchController,
                let searchResultsNavigationController = searchController.searchResultsController as? UINavigationController else {
                return true
        }
        
        if viewController == tabBarController.selectedViewController {
            for vc in navigationController.viewControllers {
                if vc.presentedViewController == searchController {
                    if searchResultsNavigationController.viewControllers.count == 1 {
                        searchController.dismiss(animated: true) {
                            self.searchController = nil
                        }
                    }
                    else {
                        searchResultsNavigationController.popToRootViewController(animated: true)
                    }
                    return false
                }
            }
        }
        
        return true
    }
}
