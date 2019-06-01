//
//  LocalizableEntity+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-16.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(LocalizableEntity)
public class LocalizableEntity: NSManagedObject {
    
    var localizedName : String {
        let language = UserDefaults.Parameters.get(forKey: .lang)!
        for localizedString in localizedNames {
            if localizedString.language == language {
                return localizedString.localizedString
            }
        }
        for localizedString in localizedNames {
            if localizedString.language == .en {
                return localizedString.localizedString
            }
        }
        if localizedNames.count > 0 {
            return localizedNames.first!.localizedString
        }
        return "Unknown"
    }

}
