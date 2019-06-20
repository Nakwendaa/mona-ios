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
    var filterPopoverViewController : FilterPopoverViewController?
    
    var searchIsActive = false {
        willSet {
            if newValue {
                let searchBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .search,
                    target: self,
                    action:#selector(searchTapped))
                addBarButtonItem(searchBarButtonItem)
            }
        }
    }
    
    var filterIsActive = false {
        willSet {
            if newValue {
                let filterBarButtonItem = UIBarButtonItem(
                    image: #imageLiteral(resourceName: "Filter Button"),
                    style: .plain,
                    target: self,
                    action: #selector(didTappedFilterButton))
                addBarButtonItem(filterBarButtonItem)
            }
        }
    }
    
    override func viewDidLoad() {
        searchIsActive = !(navigationController?.viewControllers[0] is SearchResultsController)
    }
    
    private func addBarButtonItem(_ button: UIBarButtonItem) {
        if navigationItem.rightBarButtonItems != nil {
            navigationItem.rightBarButtonItems?.insert(button, at: 0)
        }
        else {
            navigationItem.rightBarButtonItems = [button]
        }
    }
    
    @objc func searchTapped() {
        tabBarController?.delegate = self
        searchController = SearchController()
        definesPresentationContext = true
        present(searchController!, animated: true)
    }
    
    @objc func didTappedFilterButton(_ sender: UIBarButtonItem) {
        filterPopoverViewController = FilterPopoverViewController()
        filterPopoverViewController!.preferredContentSize = CGSize(width: 128, height: 128)
        filterPopoverViewController!.modalPresentationStyle = .popover
        
        if let presentationController = filterPopoverViewController!.presentationController {
            presentationController.delegate = filterPopoverViewController
        }
        
        if let popoverPresentationController = filterPopoverViewController!.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
            popoverPresentationController.passthroughViews = [view]
        }
        
        present(filterPopoverViewController!, animated: true)
        
        // We need to add the targets after calling present method
        filterPopoverViewController!.titleButton.addTarget(self, action: #selector(didTappedFilterTitleButton), for: .touchUpInside)
        filterPopoverViewController!.dateButton.addTarget(self, action: #selector(didTappedFilterDateButton), for: .touchUpInside)
        filterPopoverViewController!.distanceButton.addTarget(self, action: #selector(didTappedFilterDistanceButton), for: .touchUpInside)
    }
    
    @objc func didTappedFilterTitleButton() {}
    @objc func didTappedFilterDateButton() {}
    @objc func didTappedFilterDistanceButton() {}
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        filterPopoverViewController?.dismiss(animated: true) {
            self.filterPopoverViewController = nil
        }
        super.touchesBegan(touches, with: event)
    }
}
