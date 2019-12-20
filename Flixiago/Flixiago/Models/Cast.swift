//
//  Cast.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper

public class CastResponse: TMDBRecord {
    var id: Int64 = 0
    var cast: [CastMember]?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        cast <- map["cast"]
    }
    
}

public class CastMember: TMDBRecord, ImageProvider {
    var cast_id: Int64 = 0
    var character: String?
    var credit_id: Int64?
    var gender: Int?
    var id: Int64?
    var name: String?
    var order: Int?
    var profile_path: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        cast_id <- map["cast_id"]
        character <- map["character"]
        credit_id <- map["credit_id"]
        gender <- map["gender"]
        id <- map["id"]
        name <- map["name"]
        order <- map["order"]
        profile_path <- map["profile_path"]
    }
    
    public func getImageUrl() -> String? {
        guard let profile_path = profile_path
            else { return nil }
        
        return TMDBUrls.getProfileUrl(forWidth: 72, path: profile_path)
    }
    
    public func getImageCaption() -> String? {
        return name
    }

    public func getImageRating() -> Float? {
        return nil
    }
}
