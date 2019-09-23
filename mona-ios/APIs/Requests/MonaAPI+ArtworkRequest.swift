//
//  MonaAPI+ArtworkRequest.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

//ArtworkRequest
extension MonaAPI {
    
    struct ArtworkRequest : HTTPRequest {
        
        
        typealias Response = ArtworkResponse
        
        // The url of the request
        var url: URL = URL(string: MonaAPI.shared.baseURLString + "/user/artworks")!
        // HTTP method used by the request
        var method: HTTPMethod = .post
        // HTTP Headers of the http request
        var headers: HTTPHeaders?
        // HTTP body of the request
        var body: Data?
        
        // Init the body of the request with the parameters username, email and password
        init(id: Int, rating: Int? = nil, comment: String? = nil, photo: UIImage?) {
            let boundary = generateBoundary()
            // Headers
            headers = [
                .accept : "application/json",
                .contentType : "multipart/form-data; boundary=\(boundary)"
            ]
            
            // Parameters to encode in the body
            let parameters = [
                "api_token": UserDefaults.Credentials.get(forKey: .token)!,
                "id" : String(id),
                "rating"  : rating != nil ? String(rating!) : nil,
                "comment" : comment,
            ]
            
            body = Data()
            for (key, value) in parameters {
                if value != nil {
                    body!.append("--\(boundary)\r\n")
                    body!.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body!.append("\(value!)\r\n")
                }
            }
            
            guard let image = photo, let data = image.jpegData(compressionQuality: 0.3) else {
                body!.append("--\(boundary)--\r\n")
                return
            }
            
            //log.debug("Image size is \(data.size(unit: .useMB))")
            body!.append("--\(boundary)\r\n")
            body!.append("Content-Disposition: form-data; name=\"photo\"; filename=\"artwork-\(id).jpg\"\r\n")
            body!.append("Content-Type: image/jpeg\r\n\r\n")
            body!.append(data)
            body!.append("\r\n")
            body!.append("--\(boundary)--\r\n")
        }
        
        func execute(session: URLSession, completion: @escaping (Result<Response.HTTPDecodableResponse, HTTPError>) -> Void) {
            let response = ArtworkResponse()
            let task = session.uploadTask(with: urlRequest, from: body!, completionHandler: response.process(completion: completion))
            task.resume()
        }
        
    }
    
}
