//
//  MonaAPI+Responses.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

// Responses
extension MonaAPI {
    
    // Response of the http request
    struct ArtworkResponse : HTTPResponse {
        // Response data decoded (case http status code is 200 and data is available, we decode the response with HTTPDecodableResponse)
        typealias HTTPDecodableResponse = NilDecodableResponse
        // Response data decoded (case http status code is 422 and data is available, we decode the response with HTTPErrorDecodableResponse to know what happened)
        typealias HTTPErrorDecodableResponse = MessageErrorDecodableResponse
        
        // Return a closure to process (Data?, URLResponse?, Error?).
        // Completion: closure to handle HTTPDecodableResponse and HTTPError (occurs after process closure)
        func process(completion: ((Result<HTTPDecodableResponse, HTTPError>) -> Void)?) -> (Data?, URLResponse?, Error?) -> Void {
            return {
                data, response, error in
                if data != nil {
                    //log.debug(String(decoding: data!, as: UTF8.self))
                }
                if error != nil {
                    completion?(self.handle(.failure(error!)))
                }
                else if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(response)
                    switch result {
                    case .success(_):
                        completion?(.success(NilDecodableResponse()))
                    case .failure(let networkError):
                        switch networkError {
                        case .authenticationError(statusCode: 422):
                            guard let responseData = data else {
                                completion?(self.handle(.failure(DataError.noData)))
                                return
                            }
                            completion?(self.handle(.failure(DataError.invalidRequest(data: responseData))))
                        default:
                            completion?(self.handle(.failure(networkError)))
                        }
                    }
                }
            }
        }
        
    }
    
    // Response of the http request
    struct ArtworksResponse : HTTPResponse {
        // Response data decoded (case http status code is 200 and data is available, we decode the response with HTTPDecodableResponse)
        typealias HTTPDecodableResponse = ArtworkDecodableResponse
        // Response data decoded (case http status code is 422 and data is available, we decode the response with HTTPErrorDecodableResponse to know what happened)
        typealias HTTPErrorDecodableResponse = MessageErrorDecodableResponse
        
        // Return a closure to process (Data?, URLResponse?, Error?).
        // Completion: closure to handle HTTPDecodableResponse and HTTPError (occurs after process closure)
        func process(completion: ((Result<HTTPDecodableResponse, HTTPError>) -> Void)?) -> (Data?, URLResponse?, Error?) -> Void {
            return {
                data, response, error in
                //if data != nil {
                    //log.debug(String(decoding: data!, as: UTF8.self))
                //}
                if error != nil {
                    completion?(self.handle(.failure(error!)))
                }
                else if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(response)
                    switch result {
                    case .success(_):
                        guard let responseData = data else {
                            completion?(self.handle(.failure(DataError.noData)))
                            return
                        }
                        completion?(self.handle(.success(responseData)))
                    case .failure(let networkError):
                        switch networkError {
                        case .authenticationError(statusCode: 422):
                            guard let responseData = data else {
                                completion?(self.handle(.failure(DataError.noData)))
                                return
                            }
                            completion?(self.handle(.failure(DataError.invalidRequest(data: responseData))))
                        default:
                            completion?(self.handle(.failure(networkError)))
                        }
                    }
                }
            }
        }
        
    }
    
    // Response of the http request
    struct CredentialsResponse : HTTPResponse {
        // Response data decoded (case http status code is 200 and data is available, we decode the response with HTTPDecodableResponse)
        typealias HTTPDecodableResponse = TokenDecodableResponse
        // Response data decoded (case http status code is 422 and data is available, we decode the response with HTTPErrorDecodableResponse to know what happened)
        typealias HTTPErrorDecodableResponse = CredentialsErrorDecodableResponse
        
        // Return a closure to process (Data?, URLResponse?, Error?).
        // Completion: closure to handle HTTPDecodableResponse and HTTPError (occurs after process closure)
        func process(completion: ((Result<HTTPDecodableResponse, HTTPError>) -> Void)?) -> (Data?, URLResponse?, Error?) -> Void {
            return {
                data, response, error in
                if data != nil {
                    //log.debug(String(decoding: data!, as: UTF8.self))
                }
                if error != nil {
                    completion?(self.handle(.failure(error!)))
                }
                else if let response = response as? HTTPURLResponse {
                    let result = self.handleNetworkResponse(response)
                    switch result {
                    case .success(_):
                        guard let responseData = data else {
                            completion?(self.handle(.failure(DataError.noData)))
                            return
                        }
                        completion?(self.handle(.success(responseData)))
                    case .failure(let networkError):
                        switch networkError {
                        case .authenticationError(statusCode: 422):
                            guard let responseData = data else {
                                completion?(self.handle(.failure(DataError.noData)))
                                return
                            }
                            completion?(self.handle(.failure(DataError.invalidRequest(data: responseData))))
                        default:
                            completion?(self.handle(.failure(networkError)))
                        }
                    }
                }
            }
        }
        
    }
}
