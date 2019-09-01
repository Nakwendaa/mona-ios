//
//  MonaAPI.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

struct MonaAPI {
    
    static var shared = MonaAPI()
    var baseURLString: String = "https://picasso.iro.umontreal.ca/~mona/api"
    var apiToken : String? = {
        return UserDefaults.Credentials.get(forKey: .token)
    }()
    
    
    func artwork(id: Int, rating: Int?, comment: String?, photo: UIImage?, completion: @escaping (Result<ArtworkRequest.Response.HTTPDecodableResponse, HTTPError>) -> Void) {
        let session = URLSession.shared
        let request = ArtworkRequest(id: id, rating: rating, comment: comment, photo: photo)
        request.execute(session: session, completion: completion)
    }
    
    func artworks(completion: @escaping (Result<ArtworksRequest.Response.HTTPDecodableResponse, HTTPError>) -> Void) {
        let session = URLSession.shared
        let request = ArtworksRequest()
        request.execute(session: session, completion: completion)
    }
    
    func artworksv2() -> [ArtworkDecodableResponse.Artwork] {
        let session = URLSession.shared
        var artworks = [ArtworkDecodableResponse.Artwork]()
        var pageCount = 0
        let dispatchGroup = DispatchGroup()
        for page in 1...24 {
            dispatchGroup.enter()
            let request = ArtworksRequest(parameters: [URLQueryItem(name: "page", value: "\(page)")])
            request.execute(session: session, completion: { result in
                switch result {
                case .success(let artworksResponse):
                    if let artworksData = artworksResponse.data {
                        artworks += artworksData
                        pageCount += 1
                    }
                    dispatchGroup.leave()
                case .failure(let artworksError):
                    log.error(artworksError)
                    log.error(artworksError.localizedDescription)
                    dispatchGroup.leave()
                }
            })
        }
        dispatchGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            // All tasks are done.
            return artworks
        }))
        return artworks
    }
    
    func artworksv3(completion: @escaping (Result<ArtworksRequest.Response.HTTPDecodableResponse, HTTPError>) -> Void) {
        let session = URLSession.shared
        var artworks = [ArtworkDecodableResponse.Artwork]()
        var pageCount = 0
        let dispatchGroup = DispatchGroup()
        for page in 1...24 {
            dispatchGroup.enter()
            let request = ArtworksRequest(parameters: [URLQueryItem(name: "page", value: "\(page)")])
            request.execute(session: session, completion: { result in
                switch result {
                case .success(let artworksResponse):
                    if let artworksData = artworksResponse.data {
                        artworks += artworksData
                        pageCount += 1
                    }
                case .failure(let artworksError):
                    log.error(artworksError)
                    log.error(artworksError.localizedDescription)
                }
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            // All tasks are done.
            let r = ArtworksRequest.Response.HTTPDecodableResponse(data: artworks)
            completion(.success(r))
        }))
    }
    
    func login(username: String, password: String, completion: @escaping (Result<LoginRequest.Response.HTTPDecodableResponse, HTTPError>) -> Void) {
        let session = URLSession.shared
        let request = LoginRequest(username: username, password: password)
        request.execute(session: session, completion: completion)
    }
    
    func register(username: String, email: String?, password: String, completion: @escaping (Result<RegisterRequest.Response.HTTPDecodableResponse, HTTPError>) -> Void) {
        let session = URLSession.shared
        let request = RegisterRequest(username: username, email: email, password: password)
        request.execute(session: session, completion: completion)
    }
    
}
