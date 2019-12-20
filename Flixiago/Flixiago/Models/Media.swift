//
//  Media.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class Media: Mappable, ImageProvider {
    var id: Int64 = 0
    var poster_path: String?
    var overview: String?
    var backdrop_path: String?
    var vote_count: Int?
    var vote_average: Float?
    
    static let dateFormat = "MMMM d, y"
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        poster_path <- map["poster_path"]
        overview <- map["overview"]
        backdrop_path <- map["backdrop_path"]
        vote_count <- map["vote_count"]
        vote_average <- map["vote_average"]
    }

    func getTitle() -> String {
        fatalError("Don't call super")
    }
    
    func getGenreIds() -> [Int64] {
        fatalError("Don't call super")
    }
    
    func getReleaseDate() -> Date? {
        fatalError("Don't call super")
    }
    
    func getSeasonEpisodeText() -> String? {
        fatalError("Don't call super")
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter(
            withFormat: dateFormat,
            locale: Locale.current.identifier)
        
        return formatter.string(from: date)
    }
    
    public func formatReleaseDate() -> String {
        let date = getReleaseDate()
        if let date = date {
            return Media.formatDate(date)
        }
        
        return "Release Date Unkown"
    }
    
    func formatGenreList(lookup: GenreList.GenreLookup) -> String {
        var genreNames: [String] = []
        
        let genreIds = getGenreIds()
        
        for id in genreIds {
            genreNames.append(lookup[id] ?? "Genre Unknown")
        }
        
        return genreNames.joined(separator: " • ")
    }
    
    private func setImage(into: UIImageView, urlText: String?) {
        if let urlText = urlText,
            let url = URL(string: urlText) {
            into.kf.setImage(with: url)
        } else {
            into.image = nil
        }
    }
    
    func setBackdropImage(into: UIImageView) {
        if let poster_path = backdrop_path {
            let urlText = TMDBUrls.getBackdropUrl(
                forWidth: Float(into.frame.width),
                path: poster_path)
            
            setImage(into: into, urlText: urlText)
        } else {
            into.image = nil
        }
    }
    
    func setPosterImage(into: UIImageView) {
        if let poster_path = poster_path {
            let urlText = TMDBUrls.getPosterUrl(
                forWidth: Float(into.frame.width),
                path: poster_path)
            
            setImage(into: into, urlText: urlText)
        } else {
            into.image = nil
        }
    }
    
    static func parseDate(fromText: String?) -> Date? {
        guard let txt = fromText,
            txt.count == 10
            else { return nil }
        
        // Decode "YYYY-MM-DD"
        //         0123456789
        
        let ySt = txt.index(txt.startIndex, offsetBy: 0)
        let yEn = txt.index(txt.startIndex, offsetBy: 3)
        
        let mSt = txt.index(txt.startIndex, offsetBy: 5)
        let mEn = txt.index(txt.startIndex, offsetBy: 6)
        
        let dSt = txt.index(txt.startIndex, offsetBy: 8)
        let dEn = txt.index(txt.startIndex, offsetBy: 9)
        
        let yRange = ySt ... yEn
        let mRange = mSt ... mEn
        let dRange = dSt ... dEn
        
        let yt = txt[yRange]
        let mt = txt[mRange]
        let dt = txt[dRange]
        
        let y = Int(yt)
        let m = Int(mt)
        let d = Int(dt)
        
        var dc = DateComponents()
        dc.year = y
        dc.month = m
        dc.day = d
        
        let calendar = Calendar.current
        let result = calendar.date(from: dc)
        
        return result
    }
    
    public func getGenreList(
        callback: @escaping (TMDBService.GenreLookup?, Error?) -> Void) {
        fatalError("Don't call super")
    }
    
    public func getReviews(
        page: Int,
        callback: @escaping (ReviewResponse?, Error?) -> Void) {
        fatalError("Don't call super")
    }

    public func getCertification(
        callback: @escaping (String?, Error?) -> Void) {
    }
    
    public func getCast(
        callback: @escaping (CastResponse?, Error?) -> Void) {
        fatalError("Don't call super")
    }
    
    public func getTrailers(
        callback: @escaping (TrailersResponse?, Error?) -> Void) {
        fatalError("Don't call super")
    }
    
    public func getSimilar(
        page: Int,
        callback: @escaping ([Media]?, Error?) -> Void) {
        fatalError("Don't call super")
    }
    
    public func getDetailsRecord(
        callback: @escaping (Media?, Error?) -> Void) {
        fatalError("Don't call super")
    }
    
    public func getRunTime() -> Int {
        fatalError("Don't call super")
    }
    
    public func getSeasonCount() -> Int? {
        return nil
    }
    
    public func getImageUrl() -> String? {
        guard let poster_path = poster_path
            else { return nil }
        
        return TMDBUrls.getPosterUrl(forWidth: 107, path: poster_path)
    }

    public func getImageCaption() -> String? {
        return getTitle()
    }
    
    public func getImageRating() -> Float? {
        return vote_average ?? 0
    }
    
    public func setupFavoriteButton(into button: UIButton) {
        fatalError("Don't call super")
    }
    
    public func setupFavoriteButton(into button: UIImageView) {
        fatalError("Don't call super")
    }
    
    public func toggleFavorite(into view: UIButton) {
        fatalError("Don't call super")
    }
    
    public func toggleFavorite(into view: UIImageView) {
        fatalError("Don't call super")
    }

    private func toggleFavorite(
        type: String,
        into view: UIView) {
        
        let isFavorite = FavoriteRecord.getFavorite(
            type: type,
            id: id)
        
        FavoriteRecord.setFavorite(
            type: type,
            id: id,
            isFavorite: isFavorite == nil)
        
        if let button = view as? UIButton {
            FavoriteRecord.setupButton(
                type: type,
                id: id,
                into: button)
        } else if let image = view as? UIImageView {
            FavoriteRecord.setupButton(
                type: type,
                id: id,
                into: image)
        }
    }
    
    public func toggleFavorite(
           type: String,
           into view: UIButton) {
        toggleFavorite(type: type, into: view as UIView)
    }
    
    public func toggleFavorite(
           type: String,
           into view: UIImageView) {
        toggleFavorite(type: type, into: view as UIView)
    }
    
    public func getNoun(capitalize: Bool, plural: Bool) -> String {
        fatalError("Don't call super")
    }
}

public class Show: Media, TMDBRecord {
    var name: String?
    var first_air_date: String?
    var genre_ids: [Int64]?
    var number_of_episodes: Int?
    var number_of_seasons: Int?
    
    public static let type = "tv"
    public static let noun = "TV Show"

    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
        first_air_date <- map["first_air_date"]
        genre_ids <- map["genre_ids"]
        number_of_seasons <- map["number_of_seasons"]
        number_of_episodes <- map["number_of_episodes"]
    }
    
    public override func getTitle() -> String {
        return name ?? "<untitled>"
    }
    
    public override func getGenreIds() -> [Int64] {
        return genre_ids ?? []
    }
    
    public override func getReleaseDate() -> Date? {
        return Media.parseDate(fromText: first_air_date)
    }
    
    public override func getCertification(
        callback: @escaping (String?, Error?) -> Void) {
        
        TMDBService.getShowCertification(id: id, callback: callback)
    }
    
    public override func getGenreList(
        callback: @escaping (TMDBService.GenreLookup?, Error?) -> Void) {
        
        TMDBService.getShowGenres(callback: callback)
    }
    
    public override func getReviews(
        page: Int,
        callback: @escaping (ReviewResponse?, Error?) -> Void) {
        
        TMDBService.getShowReviews(
            id: id,
            page: page,
            callback: callback)
    }
    
    public override func getCast(
        callback: @escaping (CastResponse?, Error?) -> Void) {
        
        TMDBService.getShowCast(
            id: id,
            callback: callback)
    }
    
    public override func getTrailers(
        callback: @escaping (TrailersResponse?, Error?) -> Void) {
        
        TMDBService.getShowTrailers(
            id: id,
            callback: callback)
    }
    
    public override func getSimilar(
        page: Int,
        callback: @escaping ([Media]?, Error?) -> Void) {
        
        TMDBService.getShowsSimilar(
            id: id,
            page: page,
            callback: callback)
    }

    public override func getSeasonEpisodeText() -> String? {
        return "\(number_of_seasons ?? 0) seasons • \(number_of_episodes ?? 0) episodes"
    }

    public var description: String {
        return "Show(\(getTitle()))"
    }
    
    public override func getDetailsRecord(
        callback: @escaping (Media?, Error?) -> Void) {
        
        TMDBService.getShowDetail(id: id, callback: callback)
    }
    
    // Returns the number of episodes
    public override func getRunTime() -> Int {
        return number_of_episodes ?? 0
    }
    
    public override func getSeasonCount() -> Int? {
        return number_of_seasons
    }
    
    public override func setupFavoriteButton(into view: UIButton) {
        FavoriteRecord.setupButton(
            type: "tv",
            id: id,
            into: view)
    }
    
    public override func setupFavoriteButton(into view: UIImageView) {
        FavoriteRecord.setupButton(
            type: "tv",
            id: id,
            into: view)
    }
    
    public override func toggleFavorite(into view: UIButton) {
        toggleFavorite(type: "tv", into: view)
    }
    
    public override func toggleFavorite(into view: UIImageView) {
        toggleFavorite(type: "tv", into: view)
    }
    
    public override func getNoun(capitalize: Bool, plural: Bool) -> String {
        return (capitalize ? "TV Show" : "TV show") +
                   (plural ? "s" : "")
    }
}

public class Movie: Media, TMDBRecord {
    var title: String?
    var genre_ids: [Int64]?
    var release_date: String?
    var runtime: Int?
    
    public static let type = "movie"
    public static let noun = "movie"
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        genre_ids <- map["genre_ids"]
        title <- map["title"]
        release_date <- map["release_date"]
        runtime <- map["runtime"]
    }
    
    public override func getTitle() -> String {
        return title ?? "Title Unknown"
    }
    
    public override func getGenreIds() -> [Int64] {
        return genre_ids ?? []
    }
    
    public override func getReleaseDate() -> Date? {
        return Media.parseDate(fromText: release_date)
    }
    
    public override func getCertification(
        callback: @escaping (String?, Error?) -> Void) {
        
        TMDBService.getMovieCertification(id: id, callback: callback)
    }
    
    public override func getGenreList(
        callback: @escaping (TMDBService.GenreLookup?, Error?) -> Void) {
        
        TMDBService.getMovieGenres(callback: callback)
    }
    
    public override func getReviews(
        page: Int,
        callback: @escaping (ReviewResponse?, Error?) -> Void) {
        
        TMDBService.getMovieReviews(
            id: id,
            page: page,
            callback: callback)
    }
    
    public override func getCast(
        callback: @escaping (CastResponse?, Error?) -> Void) {
        
        TMDBService.getMovieCast(
            id: id,
            callback: callback)
    }
    
    public override func getTrailers(
        callback: @escaping (TrailersResponse?, Error?) -> Void) {
        
        TMDBService.getMovieTrailers(
            id: id,
            callback: callback)
    }
    
    public override func getSimilar(
        page: Int,
        callback: @escaping ([Media]?, Error?) -> Void) {
        
        TMDBService.getMoviesSimilar(
            id: id,
            page: page,
            callback: callback)
    }

    public override func getSeasonEpisodeText() -> String? {
        return " \(formatReleaseDate()) • \(runtime ?? 0) Minutes"
    }

    public var description: String {
        return "Movie(\(getTitle()))"
    }
    
    public override func getDetailsRecord(
        callback: @escaping (Media?, Error?) -> Void) {
        
        TMDBService.getMovieDetail(
            id: id,
            callback: callback)
    }
    
    // Returns the run time in minutes
    public override func getRunTime() -> Int {
        return runtime ?? 0
    }
    
    public override func setupFavoriteButton(into view: UIButton) {
        FavoriteRecord.setupButton(
            type: "movie",
            id: id,
            into: view)
    }
    
    public override func setupFavoriteButton(into view: UIImageView) {
        FavoriteRecord.setupButton(
            type: "movie",
            id: id,
            into: view)
    }

    public override func toggleFavorite(into view: UIButton) {
        toggleFavorite(type: "movie", into: view)
    }
    
    public override func toggleFavorite(into view: UIImageView) {
        toggleFavorite(type: "movie", into: view)
    }
    
    public override func getNoun(capitalize: Bool, plural: Bool) -> String {
        return (capitalize ? Movie.noun.capitalized : Movie.noun) +
            (plural ? "s" : "")
    }
}

public class MoviesResponse: TMDBRecord {
    var page: Int = 0
    var results: [Movie] = []
    var total_results: Int = 0
    var total_pages: Int = 0
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        page <- map["page"]
        results <- map["results"]
        total_results <- map["total_results"]
        total_pages <- map["total_pages"]
    }
}

public class ShowsResponse: TMDBRecord {
    var page: Int = 0
    var results: [Show] = []
    var total_results: Int = 0
    var total_pages: Int = 0
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        page <- map["page"]
        results <- map["results"]
        total_results <- map["total_results"]
        total_pages <- map["total_pages"]
    }
}
