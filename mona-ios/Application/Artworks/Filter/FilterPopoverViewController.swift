//
//  FilterPopoverViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-19.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class FilterPopoverViewController: UIViewController {

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var distanceButton: UIButton!
    
}

extension FilterPopoverViewController : UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}
