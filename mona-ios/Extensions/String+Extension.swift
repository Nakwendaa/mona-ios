//
//  String+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-12.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

extension String
{
    func replacingOccurences(target: String, withString: String) -> String {
        return replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeLeadingAndTrailingSpaces() -> String {
        let str = replacingOccurrences(of: "\\s+$",
                                    with: "",
                                    options: .regularExpression)
        return str.replacingOccurrences(of: "^\\s+",
                             with: "",
                             options: .regularExpression)
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
}
