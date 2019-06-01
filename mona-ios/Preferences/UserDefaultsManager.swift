//
//  UserDefaultsManager.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-14.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation
import UIKit

/*
 Goal of this API:
 
 To set: UserDefaults.Parameters.set(true, forKey: .lang)
 To get: let lang = UserDefaults.Parameters.object(forKey: .lang)
 
 See https://goo.gl/E3WtoD for more information about the logic.
 */

// MARK: - Key Namespaceable
protocol KeyNamespaceable { }

extension KeyNamespaceable {
    private static func namespace(_ key: String) -> String {
        return "\(Self.self).\(key)"
    }
    
    static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String {
        return namespace(key.rawValue)
    }
}


// MARK: - Bool Defaults
protocol BoolUserDefaultable : KeyNamespaceable {
    associatedtype BoolDefaultKey : RawRepresentable
}

extension BoolUserDefaultable where BoolDefaultKey.RawValue == String {
    
    // Set
    
    static func set(_ bool: Bool, forKey key: BoolDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(bool, forKey: key)
    }
    
    // Get
    
    static func bool(forKey key: BoolDefaultKey) -> Bool {
        let key = namespace(key)
        return UserDefaults.standard.bool(forKey: key)
    }
}


// MARK: - Float Defaults
protocol FloatUserDefaultable : KeyNamespaceable {
    associatedtype FloatDefaultKey : RawRepresentable
}

extension FloatUserDefaultable where FloatDefaultKey.RawValue == String {
    
    // Set
    
    static func set(_ float: Float, forKey key: FloatDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(float, forKey: key)
    }
    
    // Get
    
    static func float(forKey key: FloatDefaultKey) -> Float {
        let key = namespace(key)
        return UserDefaults.standard.float(forKey: key)
    }
}


// MARK: - Integer Defaults
protocol IntegerUserDefaultable : KeyNamespaceable {
    associatedtype IntegerDefaultKey : RawRepresentable
}

extension IntegerUserDefaultable where IntegerDefaultKey.RawValue == String {
    
    // Set
    
    static func set(_ integer: Int, forKey key: IntegerDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(integer, forKey: key)
    }
    
    // Get
    
    static func integer(forKey key: IntegerDefaultKey) -> Int {
        let key = namespace(key)
        return UserDefaults.standard.integer(forKey: key)
    }
}


// MARK: - Object Defaults
protocol ObjectUserDefaultable : KeyNamespaceable {
    associatedtype ObjectDefaultKey : RawRepresentable
}

extension ObjectUserDefaultable where ObjectDefaultKey.RawValue == String {
    
    // Set
    
    static func set(_ object: AnyObject, forKey key: ObjectDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(object, forKey: key)
    }
    
    // Get
    
    static func object(forKey key: ObjectDefaultKey) -> Any? {
        let key = namespace(key)
        return UserDefaults.standard.object(forKey: key)
    }
}


// MARK: - Double Defaults
protocol DoubleUserDefaultable : KeyNamespaceable {
    associatedtype DoubleDefaultKey : RawRepresentable
}

extension DoubleUserDefaultable where DoubleDefaultKey.RawValue == String {
    
    // Set
    
    static func set(_ double: Double, forKey key: DoubleDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(double, forKey: key)
    }
    
    // Get
    
    static func double(forKey key: DoubleDefaultKey) -> Double {
        let key = namespace(key)
        return UserDefaults.standard.double(forKey: key)
    }
}


// MARK: - URL Defaults
protocol URLUserDefaultable : KeyNamespaceable {
    associatedtype URLDefaultKey : RawRepresentable
}

extension URLUserDefaultable where URLDefaultKey.RawValue == String {
    
    // Set
    static func set(_ url: URL, forKey key: URLDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(url, forKey: key)
    }
    
    // Get
    static func url(forKey key: URLDefaultKey) -> URL? {
        let key = namespace(key)
        return UserDefaults.standard.url(forKey: key)
    }
}

// MARK: - String Defaults
protocol StringUserDefaultable : KeyNamespaceable {
    associatedtype StringDefaultKey : RawRepresentable
}

extension StringUserDefaultable where StringDefaultKey.RawValue == String {
    
    // Set
    
    static func set(_ string: String, forKey key: StringDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(string, forKey: key)
    }
    
    // Get
    
    static func string(forKey key: StringDefaultKey) -> String? {
        let key = namespace(key)
        return UserDefaults.standard.string(forKey: key)
    }
}


//MARK: - DataSharing Defaults
protocol DataSharingUserDefaultable : KeyNamespaceable {
    associatedtype DataSharingDefaultKey : RawRepresentable
}

/*
 enum DataSharing : String, Codable {
 case always
 case wifiOnly
 case disabled
 }
 */

/*
 extension DataSharingUserDefaultable where DataSharingDefaultKey.RawValue == String {
 
 // Set
 static func set(_ dataSharing: DataSharing, forKey key: DataSharingDefaultKey) {
 let key = namespace(key)
 UserDefaults.standard.set(dataSharing.rawValue, forKey: key)
 }
 
 // Get
 static func get(forKey key: DataSharingDefaultKey) -> DataSharing? {
 let key = namespace(key)
 
 guard let dataSharing = UserDefaults.standard.string(forKey: key) else {
 return nil
 }
 
 return DataSharing(rawValue: dataSharing)
 }
 }
 */

// MARK: - Credentials Defaults
protocol CredentialsUserDefaultable : KeyNamespaceable {
    associatedtype CredentialsDefaultKey : RawRepresentable
}

extension CredentialsUserDefaultable where CredentialsDefaultKey.RawValue == String {
    
    // Set
    static func set(_ str: String, forKey key: CredentialsDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(str, forKey: key)
    }
    
    // Get
    static func get(forKey key: CredentialsDefaultKey) -> String? {
        let key = namespace(key)
        
        guard let str = UserDefaults.standard.string(forKey: key) else {
            return nil
        }
        
        return str
    }
}


// MARK: - Language Defaults
protocol LanguageUserDefaultable : KeyNamespaceable {
    associatedtype LanguageDefaultKey : RawRepresentable
}

extension LanguageUserDefaultable where LanguageDefaultKey.RawValue == String {
    
    // Set
    
    static func set(_ language: Language, forKey key: LanguageDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(language.rawValue, forKey: key)
        Bundle.setLanguage(language)
    }
    
    // Get
    
    static func get(forKey key: LanguageDefaultKey) -> Language? {
        let key = namespace(key)
        let lang = UserDefaults.standard.integer(forKey: key)
        return Language(rawValue: Int16(lang))
    }
}



extension UserDefaults {
    
    struct Credentials : CredentialsUserDefaultable {
        
        enum CredentialsDefaultKey : String {
            case username
            case password
            case token
        }
        
        
    }
    
    //MARK: Used keys
    struct Parameters : LanguageUserDefaultable {
        
        private init() { }
        
        enum LanguageDefaultKey : String {
            case lang
        }
        
        /*
         enum DataSharingDefaultKey : String {
         case dataSharing
         }
         */
    }
    
    // default setup for UserDefaults
    func defaultSetup() {
        /*
         if UserDefaults.Parameters.get(forKey: .dataSharing) == nil {
         Parameters.set(.wifiOnly, forKey: .dataSharing)
         }
         */
        
        // Language
        setPreferredLanguage()
        if let lang = UserDefaults.Parameters.get(forKey: .lang)  {
            Bundle.setLanguage(lang)
        }
        
    }
    
    /** Set the language of the application based on the first supported language in the list of preferred languages. If no language is supported in the list of the preferred languages, choose english language by default.
     */
    private func setPreferredLanguage() {
        for langRawValue in Locale.preferredLanguages {
            let languageDict = Locale.components(fromIdentifier: langRawValue)
            if languageDict["kCFLocaleLanguageCodeKey"] == "fr" {
                UserDefaults.Parameters.set(.fr, forKey: .lang)
                return
            }
            else if languageDict["kCFLocaleLanguageCodeKey"] == "en" {
                UserDefaults.Parameters.set(.en, forKey: .lang)
                return
            }
        }
        
        if UserDefaults.Parameters.get(forKey: .lang) == nil {
            UserDefaults.Parameters.set(.en, forKey: .lang)
        }
    }
    
}
