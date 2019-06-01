//
//  NetworkError.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-26.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case authenticationError(statusCode : Int)
    case badRequest(statusCode : Int)
    case outdated(statusCode : Int)
    case failed(statusCode : Int)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationError(let statusCode):
            return "You need to be authenticated first. HTTP Code: \(statusCode)."
        case .badRequest(let statusCode):
            return "Bad request. HTTP Code: \(statusCode)."
        case .outdated(let statusCode):
            return "The url you requested is outdated. HTTP Code: \(statusCode)."
        case .failed(let statusCode):
            return "Network request failed. HTTP Code: \(statusCode)."
            
        }
    }
}
