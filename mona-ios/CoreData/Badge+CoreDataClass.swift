//
//  Badge+CoreDataClass.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-27.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Badge)
public class Badge: LocalizableEntity {
    
    var isCollected : Bool {
        return currentValue >= targetValue
    }
    
    var progress : Float {
        let value = Float(currentValue)/Float(targetValue)
        return value >= 1 ? 1 : value
    }
    
    var localizedComment : String {
        
        let language = UserDefaults.Parameters.get(forKey: .lang)!
        
        guard let comments = comments else {
            return ""
        }
        
        for localizedString in comments {
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
        
        return ""
    }

}
