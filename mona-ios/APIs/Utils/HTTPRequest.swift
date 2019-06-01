//
//  HTTPRequest.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

protocol HTTPRequest {
    associatedtype Response : HTTPResponse
    var url: URL { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var body: Data? { get }
    
    func execute(session: URLSession, completion: @escaping (Result<Response.HTTPDecodableResponse, HTTPError>) -> Void)
}

extension HTTPRequest {
    
    var urlRequest : URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if headers != nil {
            for (key, value) in headers! {
                urlRequest.addValue(value, forHTTPHeaderField: key.rawValue)
            }
        }
        urlRequest.httpBody = body
        return urlRequest
    }

    
    func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
}
