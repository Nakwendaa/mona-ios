//
//  MonaAPI+ArtworksRequest.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

//ArtworksRequest
extension MonaAPI {
    
    struct ArtworksRequest : HTTPRequest {
        
        
        typealias Response = ArtworksResponse
        
        // The url of the request
        var url: URL = URL(string: MonaAPI.shared.baseURLString + "/artworks")!
        // HTTP method used by the request
        var method: HTTPMethod = .get
        // HTTP Headers of the http request
        var headers: HTTPHeaders?
        // HTTP body of the request
        var body: Data?
        
        // Init the body of the request with the parameters username, email and password
        init(parameters: [URLQueryItem]? = nil ) {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            urlComponents.queryItems = parameters
            url = urlComponents.url!
        }
        
        func execute(session: URLSession, completion: @escaping (Result<Response.HTTPDecodableResponse, HTTPError>) -> Void) {
            let response = ArtworksResponse()
            let task = session.dataTask(with: urlRequest, completionHandler: response.process(completion: completion))
            task.resume()
        }
        
    }
    
}
