//
//  DataError.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-26.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

enum DataError : Error {
    case noData
    case invalidRequest(data: Data)
}

extension DataError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "HTTP response contains no data."
        case .invalidRequest:
            return "HTTP request was not validated by the server."
        }
    }
}
