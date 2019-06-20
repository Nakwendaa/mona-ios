//
//  UIViewController+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-18.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setTransparentNavigationBar(tintColor: UIColor) {
        navigationItem.titleView = UIView()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = tintColor
    }
    
    func setDefaultIosNavigationBar(tintColor: UIColor) {
        navigationItem.titleView = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = nil
        navigationController?.navigationBar.tintColor = tintColor
    }
    
}
