//
//  MonaAPI+LoginRequest.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation

//MARK: - LoginRequest
extension MonaAPI {
    
    struct LoginRequest : HTTPRequest {
        
        typealias Response = CredentialsResponse
        
        // The url of the request
        var url: URL = URL(string: MonaAPI.shared.baseURLString + "/login")!
        // HTTP method used by the request
        var method: HTTPMethod = .post
        // HTTP Headers of the http request
        var headers: HTTPHeaders? = [
            .accept : "application/json",
            .contentType : "application/json"
        ]
        // HTTP body of the request
        var body: Data?
        
        // Init the body of the request with the parameters username, email and password
        init(username: String, password: String) {
            let parameters = [
                "username" : username,
                "password" : password
            ]
            body = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        
        // Execute the request
        // Can be a dataTask, a uploadTask or a downloadTask
        func execute(session: URLSession, completion: @escaping (Result<Response.HTTPDecodableResponse, HTTPError>) -> Void) {
            let response = CredentialsResponse()
            let task = session.dataTask(with: urlRequest, completionHandler: response.process(completion: completion))
            task.resume()
        }
    }
}
