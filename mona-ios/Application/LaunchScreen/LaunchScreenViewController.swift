//
//  ViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-10.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    private static let gifAssetsName : [Model : String] = [
        .iPod5: "LaunchGif - Retina 4",
        .iPhone4: "LaunchGif - iPhone Portrait @2x",
        .iPhone4S: "LaunchGif - iPhone Portrait @2x",
        .iPhone5: "LaunchGif - Retina 4",
        .iPhone5C: "LaunchGif - Retina 4",
        .iPhone5S: "LaunchGif - Retina 4",
        .iPhone6: "LaunchGif - Retina HD 4.7''",
        .iPhone6Plus: "LaunchGif - Retina HD 5.5''",
        .iPhone6S: "LaunchGif - Retina HD 4.7''",
        .iPhone6SPlus: "LaunchGif - Retina HD 5.5''",
        .iPhone7: "LaunchGif - Retina HD 4.7''",
        .iPhone7Plus: "LaunchGif - Retina HD 5.5''",
        .iPhone8: "LaunchGif - Retina HD 4.7''",
        .iPhone8Plus: "LaunchGif - Retina HD 5.5''",
        .iPhoneX:"LaunchGif - Iphone Xs",
        .iPhoneXR: "LaunchGif - Iphone Xr",
        .iPhoneXS:"LaunchGif - Iphone Xs",
        .iPhoneXSMax: "LaunchGif - Iphone Xs Max"
    ]
    @IBOutlet weak var launchImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLaunchImageView()
    }

    
    private func setupLaunchImageView() {
        DispatchQueue.global().async {
            guard let gifData = self.getLaunchGifData() else {
                return
            }
            let image = UIImage.gif(data: gifData)
            DispatchQueue.main.async {
                self.launchImageView.image = image
            }
        }
    }
    
    private func getLaunchGifData() -> Data? {
        
        let deviceModel = UIDevice.current.type
        
        var assetName = LaunchScreenViewController.gifAssetsName[deviceModel]
        if assetName == nil {
            log.error("Device model " + deviceModel.rawValue + " not supported")
            assetName = LaunchScreenViewController.gifAssetsName[.iPhone6]!
        }
        
        if let dataAsset = NSDataAsset(name: assetName!) {
            return dataAsset.data
        }
        else {
            log.error("Cannot initialize NSDataAsset because \"" + assetName! + "\" was not found.")
            return nil
        }
    }
    
    deinit {
        log.debug("LaunchScreenViewController deallocated.")
    }

}

