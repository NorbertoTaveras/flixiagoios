//
//  Certification.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol Certification {
    func getCertification(forCountry: String) -> String?
}

public class MovieCertification: TMDBRecord, Certification {
    var id: Int64 = 0
    var results: [MovieCertificationResult]?

    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        results <- map["results"]
    }
    
    public func getCertification(forCountry: String) -> String? {
        guard let results = results
            else { return nil }
        
        for country in results {
            if country.country_code != forCountry {
                continue
            }
            
            guard let release_dates = country.release_dates
                else { continue }
            
            for release in release_dates {
                if !(release.certification?.isEmpty ?? true) {
                    return release.certification
                }
            }
            
            break
        }
        
        return nil
    }
}

public class ShowCertification: TMDBRecord, Certification {
    var id: Int64 = 0
    var results: [TVCertificationResult]?

    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        results <- map["results"]
    }
    
    public func getCertification(forCountry: String) -> String? {
        guard let results = results
            else { return nil }
        
        for result in results {
            if result.country_code == forCountry {
                return result.certification
            }
        }
        
        return nil
    }
}

public class MovieCertificationResult: TMDBRecord {
    var country_code: String?
    var release_dates: [MovieCertificationReleaseDate]?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        country_code <- map["iso_3166_1"]
        release_dates <- map["release_dates"]
    }
}

public class TVCertificationResult: TMDBRecord {
    var country_code: String?
    var certification: String?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        country_code <- map["iso_3166_1"]
        certification <- map["rating"]
    }
}

public class MovieCertificationReleaseDate: TMDBRecord {
    var certification: String?
    var release_date: Int64?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        certification <- map["certification"]
        release_date <- map["release_date"]
    }
}

public class CertificationListEntry: TMDBRecord {
    var certification: String?
    var meaning: String?
    var order: Int?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        certification <- map["certification"]
        meaning <- map["meaning"]
        order <- map["order"]
    }
}

public class CertificationListResponse: TMDBRecord {
    var certifications: [String: [CertificationListEntry]]?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        certifications <- map["certifications"]
    }
}
