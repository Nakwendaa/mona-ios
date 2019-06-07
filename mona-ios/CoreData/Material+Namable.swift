//
//  Material+Namable.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

extension Material : FetchableNamable {
    
    typealias T = Material
    
    var nameNamable: String {
        return localizedName
    }
    
}
