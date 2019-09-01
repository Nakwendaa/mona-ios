//
//  UIAlertController+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-13.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    
    private struct AlertAction {
        
        static func cancel(completion: (() -> Void)?) -> UIAlertAction {
            return UIAlertAction(
                title: NSLocalizedString("cancel", comment: "").capitalizingFirstLetter(),
                style: .cancel,
                handler: {
                    (_ : UIAlertAction) in
                    completion?()
                    return
                }
            )
        }
        
        static func ok(completion: (() -> Void)?) -> UIAlertAction {
            return UIAlertAction(
                title: NSLocalizedString("ok", comment: "").capitalizingFirstLetter(),
                style: .default,
                handler: {
                    (_ : UIAlertAction) in
                    completion?()
                    return
                }
            )
        }
        
        static func openSettings(completion: (() -> Void)?) -> UIAlertAction {
            return UIAlertAction(
                title: NSLocalizedString("settings", comment: "").capitalizingFirstLetter(),
                style: .default,
                handler: {
                    (_ : UIAlertAction) in
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url)
                    }
                    completion?()
                }
            )
        }
        
    }
    
    // Présenter un message de type Alert Controller qui invite l'utilisateur à ouvrir la page des paramètres de l'application
    class func presentOpenSettings(from vc: UIViewController, title: String, message: String, cancelCompletion: (() -> Void)?, openSettingsCompletion: (() -> Void)?, presentCompletion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(AlertAction.cancel(completion: cancelCompletion))
        alertController.addAction(AlertAction.openSettings(completion: openSettingsCompletion))
        vc.present(alertController, animated: true, completion: presentCompletion)
    }
    
    class func presentMessage(from vc: UIViewController, title: String, message: String, okCompletion: (() -> Void)?, presentCompletion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(AlertAction.ok(completion: okCompletion))
        vc.present(alertController, animated: true, completion: presentCompletion)
    }
    
}
