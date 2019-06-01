//
//  HTTPError.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

enum HTTPError : Error, LocalizedError {
    case unknownError(error: Error)
    case dataError(dataError: DataError)
    case networkError(networkError: NetworkError)
    case decodingError(decodingError: DecodingError)
    case requestError(httpErrorDecodableResponse: Decodable)
    
    public var errorDescription: String? {
        switch self {
        case .unknownError(let error):
            return error.localizedDescription
        case .dataError(let dataError):
            return dataError.localizedDescription
        case .networkError(let networkError):
            return networkError.localizedDescription
        case .decodingError(let decodingError):
            return decodingError.localizedDescription
        case .requestError(let httpErrorDecodableResponse):
            return "Invalid request: \(httpErrorDecodableResponse)"
        }
    }
}
