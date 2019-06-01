//
//  HTTPResponse.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

protocol HTTPResponse {
    associatedtype HTTPDecodableResponse : Decodable
    associatedtype HTTPErrorDecodableResponse : Decodable
    
    func process(completion: ((Result<HTTPDecodableResponse, HTTPError>) -> Void)?) -> (Data?, URLResponse?, Error?) -> Void
    func handle(_ result: Result<Data, Error>) -> Result<HTTPDecodableResponse, HTTPError>
}

extension HTTPResponse {
    
    // Handle Data and Error
    func handle(_ result: Result<Data, Error>) -> Result<HTTPDecodableResponse, HTTPError> {
        switch result {
        case .success(let data):
            let jsonDecoder = JSONDecoder()
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                let response = try jsonDecoder.decode(HTTPDecodableResponse.self, from: data)
                return .success(response)
            }
            catch let decodingError as DecodingError {
                return .failure(HTTPError.decodingError(decodingError: decodingError))
            }
            catch {
                return .failure(HTTPError.unknownError(error: error))
            }
        case .failure(let error):
            if let dataError = error as? DataError {
                switch dataError {
                case .invalidRequest(let data):
                    let jsonDecoder = JSONDecoder()
                    do {
                        let response = try jsonDecoder.decode(HTTPErrorDecodableResponse.self, from: data)
                        return .failure(HTTPError.requestError(httpErrorDecodableResponse: response))
                    }
                    catch let decodingError as DecodingError {
                        return .failure(HTTPError.decodingError(decodingError: decodingError))
                    }
                    catch {
                        return .failure(HTTPError.unknownError(error: error))
                    }
                default:
                    return .failure(HTTPError.dataError(dataError: dataError))
                }
            }
            else if let networkError = error as? NetworkError {
                return .failure(HTTPError.networkError(networkError: networkError))
            }
            else {
                return .failure(HTTPError.unknownError(error: error))
            }
        }
    }
    
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<Void, NetworkError> {
        switch response.statusCode {
        case 200...299: return .success(())
        case 401...500: return .failure(.authenticationError(statusCode: response.statusCode))
        case 501...599: return .failure(.badRequest(statusCode: response.statusCode))
        case 600: return .failure(.outdated(statusCode: response.statusCode))
        default: return .failure(.failed(statusCode: response.statusCode))
        }
    }
    
}
