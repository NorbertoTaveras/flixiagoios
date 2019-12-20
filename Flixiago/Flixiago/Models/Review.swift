//
//  Review.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper

public class ReviewResponse: TMDBRecord {
    var id: Int64 = 0
    var page: Int = 0
    var results: [Review]?
    var total_pages: Int?
    var total_results: Int?
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        page <- map["page"]
        results <- map["results"]
        total_pages <- map["total_pages"]
        total_results <- map["total_results"]
    }
}

class Review: TMDBRecord {
    var id: String?
    var author: String?
    var content: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        author <- map["author"]
        content <- map["content"]
    }
}
