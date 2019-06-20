//
//  UIViewLoading.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-17.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

protocol UIViewLoading {}

extension UIViewLoading where Self : UIView {
    
    // note that this method returns an instance of type `Self`, rather than UIView
    static func loadFromNib() -> Self {
        let nibName = String(describing: Self.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
    
}
