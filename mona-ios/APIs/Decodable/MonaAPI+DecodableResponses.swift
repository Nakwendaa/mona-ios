//
//  MonaAPI+DecodableResponses.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-28.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation
//MARK: - Decodable Responses
extension MonaAPI {
    
    //MARK: HTTPDecodableResponse
    struct NilDecodableResponse : Codable {}
    
    
    struct TokenDecodableResponse : Codable {
        let token : String
    }
    
    
    struct ArtworkDecodableResponse: Codable {
        
        enum CodingKeys : String, CodingKey {
            case data
        }
        
        struct Artwork : Codable {
            
            enum CodingKeys : String, CodingKey {
                case id
                case title
                case date = "produced_at"
                case category
                case subcategory
                case dimensions
                case materials
                case techniques
                case district = "borough"
                case artists
                case coordinate = "location"
            }
            
            struct Artist : Codable {
                
                enum CodingKeys : String, CodingKey {
                    case id
                    case name
                    case isCollectiveName = "collective"
                }
                
                let id: Int16
                let name: String
                let isCollectiveName : Bool
                
            }
            
            struct Category : Codable {
                
                enum CodingKeys : String, CodingKey {
                    case fr
                    case en
                }
                
                let fr: String?
                let en: String?
                
            }
            
            struct Coordinate : Codable {
                
                enum CodingKeys : String, CodingKey {
                    case latitude = "lat"
                    case longitude = "lng"
                }
                
                let latitude: Double?
                let longitude: Double?
                
            }
            
            struct Subcategory : Codable {
                
                enum CodingKeys : String, CodingKey {
                    case fr
                    case en
                }
                
                let fr: String?
                let en: String?
                
            }
            
            struct Material : Codable {
                
                enum CodingKeys : String, CodingKey {
                    case fr
                    case en
                }
                
                let fr: String?
                let en: String?
                
            }
            
            struct Technique : Codable {
                
                enum CodingKeys : String, CodingKey {
                    case fr
                    case en
                }
                
                let fr: String?
                let en: String?
                
            }
            
            let id : Int16
            let title : String?
            let date : Date?
            let artists : [Artist]?
            let category : Category?
            let subcategory : Subcategory?
            let dimensions : [String]?
            let materials : [Material]?
            let techniques : [Technique]?
            let district : String?
            let coordinate : Coordinate?
        }
        
        let data : [Artwork]?
        
    }
    
    //MARK: HTTPErrorDecodableResponse
    struct MessageErrorDecodableResponse : Codable {
        let message : String
    }
    
    struct CredentialsErrorDecodableResponse : Codable, CustomStringConvertible {
        let message : String
        let errors : RegisterErrorDetails
        
        struct RegisterErrorDetails : Codable {
            let username : [String]?
            let email : [String]?
            let password : [String]?
        }
        
        var description: String {
            var result = message
            if let usernameErrors = errors.username {
                result += "\nusername: " + usernameErrors.joined(separator: ", ")
            }
            if let emailErrors = errors.email {
                result += "\nemail: " + emailErrors.joined(separator: ", ")
            }
            if let passwordErrors = errors.password {
                result += "\npassword: " + passwordErrors.joined(separator: ", ")
            }
            return result
        }
    }
    
    
}
