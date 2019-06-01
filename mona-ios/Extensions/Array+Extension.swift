//
//  Array+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-17.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}
