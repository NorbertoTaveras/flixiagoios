//
//  Genre.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class Genre: TMDBRecord {
    var id: Int64 = 0
    var name: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}

public class GenreList: TMDBRecord {
    var genres: [Genre] = []
    
    public typealias GenreLookup = [Int64: String]
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        genres <- map["genres"]
    }
    
    public func makeLookupTable() -> GenreLookup {
        var table: [Int64: String] = [:]
        
        for genre in genres {
            table[genre.id] = genre.name
        }
        
        return table
    }
}
