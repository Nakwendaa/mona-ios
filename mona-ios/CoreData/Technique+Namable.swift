//
//  Technique+Namable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

extension Technique : Namable {
    typealias T = Technique
    
    var nameNamable: String {
        return localizedName
    }
    
}
