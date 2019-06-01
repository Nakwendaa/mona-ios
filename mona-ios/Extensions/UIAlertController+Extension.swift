//
//  UIAlertController+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-13.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    private struct AlertActions {
        
        static var cancel : UIAlertAction {
            return UIAlertAction(
                title: NSLocalizedString("cancel", comment: "").capitalizingFirstLetter(),
                style: .cancel,
                handler: {
                    (_ : UIAlertAction) in
                    return
            }
            )
        }
        
        static var ok : UIAlertAction {
            return UIAlertAction(
                title: NSLocalizedString("ok", comment: "").capitalizingFirstLetter(),
                style: .default,
                handler: {
                    (_ : UIAlertAction) in
                    return
            }
            )
        }
        
        static var openSettings : UIAlertAction {
            return UIAlertAction(
                title: NSLocalizedString("settings", comment: "").capitalizingFirstLetter(),
                style: .default,
                handler: {
                    (_ : UIAlertAction) in
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url)
                    }
            }
            )
        }
        
    }
    
    // Présenter un message de type Alert Controller qui invite l'utilisateur à ouvrir la page des paramètres de l'application
    class func presentOpenSettings(from vc: UIViewController, title: String, message: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(AlertActions.cancel)
        alertController.addAction(AlertActions.openSettings)
        vc.present(alertController, animated: true, completion: completion)
        
    }
    
    class func presentMessage(from vc: UIViewController, title: String, message: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(AlertActions.ok)
        vc.present(alertController, animated: true, completion: completion)
    }
    
}
