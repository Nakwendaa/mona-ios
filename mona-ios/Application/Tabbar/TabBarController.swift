//
//  TabBarController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class TabBarController: UITabBarController, Contextualizable {
    
    var viewContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Pass current viewContext to rootViewControllers of each tab
        viewControllers?.forEach { viewController in
            if var contextualizableViewController = viewController as? Contextualizable {
                contextualizableViewController.viewContext = viewContext
            }
        }
    }

}
