//
//  TMDBUrls.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation

class TMDBUrls {
    public private(set) static var BASE = "http://image.tmdb.org/t/p"
    public private(set) static var IMAGE_BASE_URL_154px = BASE + "w154"
    
    private static let backdrop_sizes = [
        300,
        780,
        1280
    ]
    
    private static let logo_sizes = [
        45,
        92,
        154,
        185,
        300,
        500
    ]
    
    private static let poster_sizes = [
        92,
        154,
        185,
        342,
        500,
        780
    ]

    private static let profile_sizes = [
        45,
        185
    ]

    private static let still_sizes = [
        92,
        185,
        300
    ]
    
    // Find the lowest size >= size
    private static func closestWidth(sizes: [Int], size: Int) -> Int {
        var st = 0
        var en = sizes.count
        while st < en {
            let md = st + ((en - st) >> 1)
            let it = sizes[md]
            if it < size {
                st = md + 1
            } else {
                en = md
            }
        }
        
        if st == sizes.count {
            st = sizes.count - 1
        }
        
        return sizes[st]
    }
    
    public static func closestBackdropWidth(size: Int) -> Int {
        return closestWidth(sizes: backdrop_sizes, size: size)
    }
    
    public static func closestPosterWidth(size: Int) -> Int {
        return closestWidth(sizes: poster_sizes, size: size)
    }
    
    public static func closestProfileWidth(size: Int) -> Int {
        return closestWidth(sizes: profile_sizes, size: size)
    }
    
    public static func getBackdropUrl(forWidth: Float,
                                      path: String) -> String {
        let closest = closestBackdropWidth(size: Int(forWidth))
        let url = "\(BASE)/w\(closest)/\(path)"
        return url
    }

    public static func getPosterUrl(forWidth: Float,
                                      path: String) -> String {
        let closest = closestPosterWidth(size: Int(forWidth))
        let url = "\(BASE)/w\(closest)\(path)"
        return url
    }
    
    public static func getProfileUrl(forWidth: Float,
                                     path: String) -> String {
        let closest = closestProfileWidth(size: Int(forWidth))
        let url = "\(BASE)/w\(closest)/\(path)"
        return url
    }
}
