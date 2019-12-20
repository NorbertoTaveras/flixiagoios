//
//  Trailer.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper

public class TrailersResponse: TMDBRecord {
    var id: Int64 = 0
    var key: String?
    var results: [Trailer]?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        key <- map["key"]
        results <- map["results"]
    }
}

public class Trailer: TMDBRecord, ImageProvider, VideoProvider {
    var id: String?
    var key: String?
    
    private static let VIDEO_THUMBNAIL_BASE_URL_FORMAT =
        "http://img.youtube.com/vi/%@/0.jpg"
    
    private static let VIDEO_BASE_URL_FORMAT =
        "http://www.youtube.com/watch?v=%@"
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        key <- map["key"]
    }
    
    public func getImageUrl() -> String? {
        guard let key = key
            else { return nil }
    
        return String(
            format: Trailer.VIDEO_THUMBNAIL_BASE_URL_FORMAT,
            key)
   }
   
    public func getImageCaption() -> String? {
        return nil
    }
    
    public func getVideoThumbnailUrl() -> String? {
        guard let key = key
            else { return nil }
        
        return String(
            format: Trailer.VIDEO_THUMBNAIL_BASE_URL_FORMAT,
            key)
    }
    
    public func getVideoUrl() -> String? {
        guard let key = key
            else { return nil }
        
        return String(
            format: Trailer.VIDEO_BASE_URL_FORMAT,
            key)
    }
    
    public func getImageRating() -> Float? {
        return nil
    }
}
