//
//  TMDBService.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

public protocol TMDBRecord : Mappable {
    
}

public class TMDBService {
    static let API_KEY = "440f271c026c7acdb889c9c109f49daa"
    
    static let BASE_URL = "https://api.themoviedb.org/"
    static let LANGUAGE = "en-US"
    static let COUNTRY = "US"
    
    static let POPULAR = "popular"

    static let TOP_RATED = "top_rated"

    static let UPCOMING = "upcoming"
    static let NOW_PLAYING = "now_playing"
    
    static let AIRING_TODAY = "airing_today"
    static let ON_THE_AIR = "on_the_air"
    
    public typealias SortByPair = (text: String, sortBy: String)
    
    public static let movieSortBys: [SortByPair] = [
        ("Popular", POPULAR),
        ("Top Rated", TOP_RATED),
        ("Upcoming", UPCOMING),
        ("Now Playing", NOW_PLAYING)
    ]
    
    public static let showSortBys: [SortByPair] = [
        ("Popular", POPULAR),
        ("Top Rated", TOP_RATED),
        ("On The Air", ON_THE_AIR),
        ("Airing Today", AIRING_TODAY)
    ]

    public typealias GenreLookup = GenreList.GenreLookup
    
    // Aggressively cache genre list
    private static var cachedGenresMovie: GenreLookup?
    private static var cachedGenresShow: GenreLookup?
    
    public static func request<T: TMDBRecord>(
        urlText: String,
        callback: @escaping (T?, Error?) -> Void) {
        
        Alamofire.request(urlText).responseObject {
            (response: DataResponse<T>) in
            if let error = response.error {
                callback(nil, error)
            } else {
                callback(response.value, nil)
            }
        }
    }
    
    public static func request<T: TMDBRecord>(
        urlText: String,
        callback: @escaping ([T]?, Error?) -> Void) {
        
        Alamofire.request(urlText).responseArray {
            (response: DataResponse<[T]>) in
            if let error = response.error {
                callback(nil, error)
            } else {
                callback(response.value, nil)
            }
        }
    }
    
    public static func getMovies(
        sortBy: String,
        page: Int,
        language: String,
        callback: @escaping (MoviesResponse?, Error?) -> Void) {
        
        let encodedSortBy = sortBy.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed) ?? ""
        
        let urlText = getUrl(path: "3/movie/\(encodedSortBy)", query: [
            "page": String(page),
            "language": TMDBService.LANGUAGE
        ])

        request(urlText: urlText, callback: callback)
    }
    
    public static func searchMovies(
        genreId: Int64,
        page: Int,
        callback: @escaping (MoviesResponse?, Error?) -> Void) {
            
            let urlText = getUrl(path: "3/discover/movie", query: [
                "with_genres": String(genreId),
                "language": TMDBService.LANGUAGE,
                "page": String(page)
            ])
            
            request(urlText: urlText, callback: callback)
    }
    
    public static func searchMovies(
        query: String,
        page: Int,
        callback: @escaping (MoviesResponse?, Error?) -> Void) {
        
        let urlText = getUrl(path: "3/search/movie", query: [
            "query": query,
            "language": TMDBService.LANGUAGE,
            "page": String(page)
        ])
        
        request(urlText: urlText, callback: callback)
    }
    
    public static func getShows(
        sortBy: String,
        page: Int,
        language: String,
        callback: @escaping (ShowsResponse?, Error?) -> Void) {
        
        let encodedSortBy = sortBy.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed) ?? ""
        
        let urlText = getUrl(path: "3/tv/\(encodedSortBy)", query: [
            "page": String(page),
            "language": TMDBService.LANGUAGE
        ])

        request(urlText: urlText, callback: callback)
    }
    
    public static func searchShows(
        query: String,
        page: Int,
        callback: @escaping (ShowsResponse?, Error?) -> Void) {
        
        let urlText = getUrl(path: "3/search/tv", query: [
            "query": query,
            "language": TMDBService.LANGUAGE,
            "page": String(page)
        ])
        
        request(urlText: urlText, callback: callback)
    }
    
    public static func searchShows(
        genreId: Int64,
        page: Int,
        callback: @escaping (ShowsResponse?, Error?) -> Void) {
            
            let urlText = getUrl(path: "3/discover/tv", query: [
                "with_genres": String(genreId),
                "language": TMDBService.LANGUAGE,
                "page": String(page)
            ])
            
            request(urlText: urlText, callback: callback)
    }

    public static func getDetail<T: TMDBRecord>(
        id: Int64, type: String,
        callback: @escaping (T?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/\(type)/\(id)", query:
            ["language": TMDBService.LANGUAGE])
        
        request(urlText: urlText, callback: callback)
    }
    
    public enum TMDBErrors : Error {
        case InvalidType
    }
    
    public static func getMediaDetail(
        id: Int64, type: String,
        callback: @escaping (Media?, Error?) -> Void) {
        switch type {
        case "movie":
            TMDBService.getMovieDetail(id: id, callback: callback)
            
        case "tv":
            TMDBService.getShowDetail(id: id, callback: callback)
            
        default:
            callback(nil, TMDBErrors.InvalidType)
            
        }
    }
    
    public static func getMovieDetail(
        id: Int64,
        callback: @escaping (Movie?, Error?) -> Void) {
        
        getDetail(id: id, type: "movie", callback: callback)
    }
    
    public static func getShowDetail(
        id: Int64,
        callback: @escaping (Show?, Error?) -> Void) {
        
        getDetail(id: id, type: "tv", callback: callback)
    }

    public static func getShowsSimilar(
        id: Int64,
        page: Int,
        callback: @escaping ([Media]?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/tv/\(id)/similar",
            query: [
                "page": String(page),
                "language": TMDBService.LANGUAGE
        ])
        
        request(urlText: urlText) {
            (showsResponse: ShowsResponse?, error) in
            callback(showsResponse?.results, error)
        }
    }
    
    public static func getMoviesSimilar(
        id: Int64,
        page: Int,
        callback: @escaping ([Media]?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/movie/\(id)/similar",
            query: [
                "page": String(page),
                "language": TMDBService.LANGUAGE
        ])
        
        request(urlText: urlText) {
            (moviesResponse: MoviesResponse?, error) in
            callback(moviesResponse?.results, error)
        }
    }

    public static func getGenres(type: String,
                                 callback: @escaping (GenreList?, Error?) -> Void) {
        let encodedType = type.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed) ?? ""
        
        let urlText = getUrl(
            path: "3/genre/\(encodedType)/list",
            query: [
                "language": TMDBService.LANGUAGE
        ])
        
        request(urlText: urlText, callback: callback)
    }
    
    public static func getMovieGenres(
        callback: @escaping (GenreLookup?, Error?) -> Void) {
        
        if cachedGenresMovie != nil {
            callback(cachedGenresMovie, nil)
            return
        }
        
        getGenres(type: "movie") { (list, error) in
            if error != nil {
                callback(nil, error)
                return
            }
            
            if let list = list {
                cachedGenresMovie = list.makeLookupTable()
            }
            
            callback(cachedGenresMovie, nil)
        }
    }
    
    public static func getShowGenres(
        callback: @escaping (GenreLookup?, Error?) -> Void) {
        
        getGenres(type: "tv") { (list, error) in
            if error != nil {
                callback(nil, error)
                return
            }
            
            if let list = list {
                cachedGenresShow = list.makeLookupTable()
            }
            
            callback(cachedGenresShow, nil)
        }
    }
    
    public static func getMovieCertification(
        id: Int64,
        callback: @escaping (String?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/movie/\(id)/release_dates",
            query: [:])
        
        request(urlText: urlText) { (certs: MovieCertification?, error: Error?) in
            callback(certs?.getCertification(forCountry: COUNTRY), error)
        }
    }
    
    public static func getShowCertification(
        id: Int64,
        callback: @escaping (String?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/tv/\(id)/content_ratings",
            query: [:])
        
        request(urlText: urlText) { (certs: ShowCertification?, error: Error?) in
            callback(certs?.getCertification(forCountry: COUNTRY), error)
        }
    }
    
    private static func getReviews(
        id: Int64,
        type: String,
        page: Int,
        callback: @escaping (ReviewResponse?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/\(type)/\(id)/reviews",
            query: [
                "page": String(page),
                "language": LANGUAGE
        ])
        
        request(urlText: urlText, callback: callback)
    }
    
    public static func getMovieReviews(
        id: Int64,
        page: Int,
        callback: @escaping (ReviewResponse?, Error?) -> Void) {
        
        getReviews(id: id, type: "movie", page: page, callback: callback)
    }

    public static func getShowReviews (
        id: Int64,
        page: Int,
        callback: @escaping (ReviewResponse?, Error?) -> Void) {
        
        getReviews(id: id, type: "tv", page: page, callback: callback)
    }
    
    private static func getCast(
        id: Int64,
        type: String,
        callback: @escaping (CastResponse?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/\(type)/\(id)/credits",
            query: [:])
        
        request(urlText: urlText, callback: callback)
    }

    
    public static func getMovieCast(
        id: Int64,
        callback: @escaping (CastResponse?, Error?) -> Void) {
        
        getCast(id: id, type: "movie", callback: callback)
    }
        
    public static func getShowCast(
        id: Int64,
        callback: @escaping (CastResponse?, Error?) -> Void) {
        
        getCast(id: id, type: "tv", callback: callback)
    }

    private static func getTrailers(
        id: Int64,
        type: String,
        callback: @escaping (TrailersResponse?, Error?) -> Void) {
        
        let urlText = getUrl(
            path: "3/\(type)/\(id)/videos",
            query: [
                "language": LANGUAGE
        ])
        
        request(urlText: urlText, callback: callback)
    }
    
    public static func getMovieTrailers(
        id: Int64,
        callback: @escaping (TrailersResponse?, Error?) -> Void) {
        
        getTrailers(
            id: id,
            type: "movie",
            callback: callback)
    }
    
    public static func getShowTrailers(
        id: Int64,
        callback: @escaping (TrailersResponse?, Error?) -> Void) {
        
        getTrailers(
            id: id,
            type: "tv",
            callback: callback)
    }
    
    static func urlEncodedKVP(key: String, value: String) -> String {
        let encodedKey = key.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed)
        
        let encodedValue = value.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed)
        
        return "\(encodedKey ?? "")=\(encodedValue ?? "")"
    }
    
    public static func getUrl(
        path: String,
        query: [String: String],
        auto: Bool = true) -> String {
        
        var parts: [String] = []
        
        if auto {
            parts.append(urlEncodedKVP(
                key: "api_key",
                value: TMDBService.API_KEY
            ))
        }
        
        for (key, value) in query {
            parts.append(urlEncodedKVP(key: key, value: value))
        }
        
        let query: String
        
        if parts.count > 0 {
            query = "?" + parts.joined(separator: "&")
        } else {
            query = ""
        }
        
        return TMDBService.BASE_URL + path + query
    }
}
