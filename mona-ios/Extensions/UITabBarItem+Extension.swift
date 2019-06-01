//
//  UITabBarItem+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-13.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

@IBDesignable extension UITabBarItem {
    
    @IBInspectable var localisedKey: String? {
        set {
            guard let key = newValue else {
                return
            }
            title = NSLocalizedString(key, tableName: "Tabbar", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
        get {
            return ""
        }
    }
}
