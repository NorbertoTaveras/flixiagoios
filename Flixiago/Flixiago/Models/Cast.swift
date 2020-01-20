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
        mapping(map: map)
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

public class Person: TMDBRecord, ImageProvider {
    var id: Int64 = 0
    var name: String?
    var known_for_department: String?
    var biography: String?
    var birthday: String?
    var place_of_birth: String?
    var profile_path: String?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        birthday <- map["birthday"]
        known_for_department <- map["known_for_department"]
        biography <- map["biography"]
        place_of_birth <- map["place_of_birth"]
        profile_path <- map["profile_path"]
    }
    
    public func setImage(into view: UIImageView) {
        view.image = nil
        
        guard let profile_path = profile_path
            else { return }
        
        let urlText = TMDBUrls.getProfileUrl(forWidth: 72, path: profile_path)
        
        guard let url = URL(string: urlText)
            else { return }
        
        view.kf.setImage(with: url)
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
    
    public func getBirthdate() -> Date? {
        guard let birthday = birthday
            else { return nil }
        
        return Media.parseDate(fromText: birthday)
    }
    
    public func formatBirthdate() -> String? {
        guard let birthdate = getBirthdate()
            else { return nil }
        
        return UIUtils.formatDate(from: birthdate)
    }
}

public class PersonImages: TMDBRecord {
    var id: Int64 = 0
    var profiles: [PersonImage]?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        profiles <- map["profiles"]
    }
}

public class PersonImage: TMDBRecord, ImageProvider {
    var file_path: String?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        file_path <- map["file_path"]
    }
    
    public func getImageUrl() -> String? {
        guard let file_path = file_path
            else { return nil }
        
        return TMDBUrls.getProfileUrl(forWidth: 72, path: file_path)
    }
    
    public func getImageCaption() -> String? {
        return nil
    }
    
    public func getImageRating() -> Float? {
        return nil
    }
}

public class PersonCombinedCreditsResponse: TMDBRecord {
    var id: Int64 = 0
    var roles: [PersonCombinedCreditsRole]?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        roles <- map["cast"]
    }
}

public class PersonCombinedCreditsRole: TMDBRecord, ImageProvider {
    var id: Int64 = 0
    var name: String?
    var media_type: String?
    var genre_ids: [Int64]?
    var profile_path: String?
    var vote_average: Float?
    var release_date: String?
    var character: String?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        media_type <- map["media_type"]
        profile_path <- map["poster_path"]
        genre_ids <- map["genre_ids"]
        character <- map["character"]
        vote_average <- map["vote_average"]
        
        switch media_type {
        case "tv":
            name <- map["name"]
            release_date <- map["first_air_date"]
            break
            
        case "movie":
            name <- map["title"]
            release_date <- map["release_date"]
            break
            
        default:
            break
        }
    }
    
    public func getImageUrl() -> String? {
        guard let profile_path = profile_path
            else { return nil }
        
        return TMDBUrls.getProfileUrl(
            forWidth: 72,
            path: profile_path)
    }
    
    public func getImageCaption() -> String? {
        return name
    }
    
    public func getImageRating() -> Float? {
        return vote_average
    }
}
