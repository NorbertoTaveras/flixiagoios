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
    
    public required init?(map: Map) {
        mapping(map: map)
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
        return UIUtils.formatDate(from: date)
    }
    
    public func formatReleaseDate() -> String {
        let date = getReleaseDate()
        if let date = date {
            return Media.formatDate(date)
        }
        
        return "Release Date Unkown"
    }
    
    public static func formatGenreList(
        genreIds: [Int64],
        lookup: GenreList.GenreLookup) -> String {
        
        var genreNames: [String] = []
        
        for id in genreIds {
            genreNames.append(lookup[id] ?? "Genre Unknown")
        }
        
        return genreNames.joined(separator: " • ")
    }

    func formatGenreList(lookup: GenreList.GenreLookup) -> String {
        let genreIds = getGenreIds()
        
        return Media.formatGenreList(
            genreIds: genreIds,
            lookup: lookup)
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
    
    @discardableResult
    public func setupButton(
        kind: String,
        type: String,
        into button: UIButton)
        -> FavoriteRecord? {
            
        return FavoriteRecord.setupButton(
            kind: kind,
            type: type,
            id: id,
            into: button)
    }
    
    @discardableResult
    public func setupButton(
        kind: String,
        type: String,
        into image: UIImageView)
        -> FavoriteRecord? {
        
        return FavoriteRecord.setupButton(
            kind: kind,
            type: type,
            id: id,
            into: image)
    }
    
    public class FavoriteToggler: NSObject {
        let media: Media?
        let id: Int64?
        let kind: String
        let type: String
        let view: UIView
        
        init(kind: String,
             type: String,
             media: Media?,
             id: Int64?,
             into view: UIView) {
            self.kind = kind
            self.type = type
            self.media = media
            self.id = id
            self.view = view
            super.init()
            setupTap()
        }
        
        @objc public func toggleTapped(sender: UITapGestureRecognizer) {
            if let media = media {
                // Show and movie need the full media object
                if let button = view as? UIButton {
                    media.toggle(kind: kind, into: button)
                } else if let imageView = view as? UIImageView {
                    media.toggle(kind: kind, into: imageView)
                }
            } else if let id = id {
                // No detail needed
                FavoriteRecord.toggle(
                    kind: kind,
                    type: type,
                    id: id,
                    into: view)
            } else {
                fatalError("No idea what to do")
            }
        }
        
        func setupTap() {
            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(toggleTapped))
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    // Setup a favorite/watch button, and attach tap handlers
    public func autoButton(
        kind: String,
        into view: UIView) -> FavoriteToggler {
        
        let type = getMediaType()
        
        if let button = view as? UIButton {
            setupButton(
                kind: kind,
                type: type,
                into: button)
        } else if let imageView = view as? UIImageView {
            setupButton(
                kind: kind,
                type: type,
                into: imageView)
        } else {
            fatalError("Unhandled view type")
        }
        
        let toggler = FavoriteToggler(
            kind: kind,
            type: type,
            media: self,
            id: nil,
            into: view)
        
        return toggler
    }

    @discardableResult
    public func setupFavoriteButton(
        into button: UIButton) -> FavoriteRecord? {
        
        return setupButton(kind: "f", type: getMediaType(), into: button)
    }
    
    @discardableResult
    public func setupFavoriteButton(
        into image: UIImageView) -> FavoriteRecord? {
        
        return setupButton(kind: "f", type: getMediaType(), into: image)
    }
    
    @discardableResult
    public func setupWatchButton(
        into button: UIButton) -> FavoriteRecord? {
        
        return setupButton(kind: "w", type: getMediaType(), into: button)
    }
    
    @discardableResult
    public func setupWatchButton(
        into image: UIImageView) -> FavoriteRecord? {
        
        return setupButton(kind: "w", type: getMediaType(), into: image)
    }

    @discardableResult
    public func toggle(
        kind: String,
        into button: UIButton)
        -> FavoriteRecord? {
            
        return toggle(kind: kind, type: getMediaType(), into: button)
    }
    
    @discardableResult
    public func toggle(
        kind: String,
        into imageView: UIImageView)
        -> FavoriteRecord? {
            
        return toggle(kind: kind, type: getMediaType(), into: imageView)
    }
    
    @discardableResult
    public func toggleFavorite(
        into view: UIImageView) -> FavoriteRecord? {
        
        return toggle(kind: "f", into: view)
    }
    
    @discardableResult
    public func toggleFavorite(
        into button: UIButton)
        -> FavoriteRecord? {
            
        return toggle(kind: "f", into: button)
    }
    
    @discardableResult
    public func toggleWatch(
        into button: UIButton)
        ->FavoriteRecord? {
            
        return toggle(kind: "w", into: button)
    }

    @discardableResult
    public func toggleWatch(
        into image: UIImageView)
        -> FavoriteRecord? {
            
        return toggle(kind: "w", into: image)
    }

    @discardableResult
    public func toggle(
        kind: String,
        type: String,
        into view: UIView)
        -> FavoriteRecord? {
        
        var record = FavoriteRecord.get(
            kind: kind,
            type: type,
            id: id)
        
        let wasOn = record?.favorite ?? false
        
        record = FavoriteRecord.set(
            kind: kind,
            type: type,
            id: id,
            isFavorite: !wasOn)
        
        if let button = view as? UIButton {
            record = FavoriteRecord.setupButton(
                kind: kind,
                type: type,
                id: id,
                into: button)
        } else if let image = view as? UIImageView {
            record = FavoriteRecord.setupButton(
                kind: kind,
                type: type,
                id: id,
                into: image)
        }
        
        if let record = record {
            FirestoreService.set(
                kind: kind,
                type: type,
                media: self,
                id: nil,
                timestamp: record.timestamp,
                watched: !wasOn) { (error) in
                    if error != nil {
                        print(error as Any)
                    }
            }
        }
            
        return record
    }

    public func getMediaType() -> String {
        fatalError("Don't call super")
    }
    
    public func getNoun(capitalize: Bool, plural: Bool) -> String {
        fatalError("Don't call super")
    }
}

public class Show: Media, TMDBRecord {
    var name: String?
    var first_air_date: String?
    var genre_ids: [Int64]?
    var genres: [Genre]?
    var number_of_episodes: Int?
    var number_of_seasons: Int?
    var seasons: [ShowSeason]?
    
    public static let type = "tv"
    public static let noun = "TV Show"
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
        first_air_date <- map["first_air_date"]
        genres <- map["genres"]
        number_of_seasons <- map["number_of_seasons"]
        number_of_episodes <- map["number_of_episodes"]
        seasons <- map["seasons"]
        genre_ids <- map["genre_ids"]
    }
    
    public override func getTitle() -> String {
        return name ?? "<untitled>"
    }
    
    public override func getGenreIds() -> [Int64] {
        if let genre_ids = genre_ids {
            return genre_ids
        }
        
        genre_ids = []
        
        for genre in genres ?? [] {
            genre_ids!.append(genre.id)
        }
        
        return genre_ids!
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

    @discardableResult
    public override func setupFavoriteButton(
        into view: UIButton) -> FavoriteRecord? {
        
        return FavoriteRecord.setupButton(
            kind: "f",
            type: "tv",
            id: id,
            into: view)
    }
    
    @discardableResult
    public override func setupFavoriteButton(
        into view: UIImageView) -> FavoriteRecord? {
        
        return FavoriteRecord.setupButton(
            kind: "f",
            type: "tv",
            id: id,
            into: view)
    }
    
    @discardableResult
    public override func setupWatchButton(
        into view: UIButton) -> FavoriteRecord? {
        
        return FavoriteRecord.setupButton(
            kind: "w",
            type: "tv",
            id: id,
            into: view)
    }
    
    @discardableResult
    public override func setupWatchButton(
        into view: UIImageView) -> FavoriteRecord? {
        
        return FavoriteRecord.setupButton(
            kind: "w",
            type: "tv",
            id: id,
            into: view)
    }
    
    @discardableResult
    public override func toggle(
        kind: String,
        into button: UIButton) -> FavoriteRecord? {
        
        return toggle(kind: kind, type: "tv", into: button)
    }
    
    @discardableResult
    public override func toggle(
        kind: String,
        into image: UIImageView)
        -> FavoriteRecord? {
            
        return toggle(kind: kind, type: "tv", into: image)
    }

    public override func getMediaType() -> String {
        return "tv"
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

    public override func setupFavoriteButton(
        into view: UIImageView)
        -> FavoriteRecord? {
            
        return FavoriteRecord.setupFavoriteButton(
            type: "movie",
            id: id,
            into: view)
    }
    
    public override func setupWatchButton(
        into view: UIButton)
        -> FavoriteRecord? {
            
        return FavoriteRecord.setupWatchButton(
            type: "movie",
            id: id,
            into: view)
    }
    
    public override func setupWatchButton(
        into view: UIImageView)
        -> FavoriteRecord? {
            
        return FavoriteRecord.setupWatchButton(
            type: "movie",
            id: id,
            into: view)
    }
    
    public override func toggle(
        kind: String,
        into button: UIButton)
        -> FavoriteRecord? {
            
        return toggle(kind: kind, type: "movie", into: button)
    }
    
    public override func toggle(
        kind: String,
        into image: UIImageView)
        -> FavoriteRecord? {
            
        return toggle(kind: kind, type: "movie", into: image)
    }

    public override func getMediaType() -> String {
        return "movie"
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
        mapping(map: map)
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
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        page <- map["page"]
        results <- map["results"]
        total_results <- map["total_results"]
        total_pages <- map["total_pages"]
    }
}

public class ShowSeason: TMDBRecord, ImageProvider {
    var id: Int64 = 0
    var air_date: String?
    var episode_count: Int?
    var name: String?
    var overview: String?
    var poster_path: String?
    var season_number: Int?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        air_date <- map["air_date"]
        episode_count <- map["episode_count"]
        name <- map["name"]
        overview <- map["overview"]
        poster_path <- map["poster_path"]
        season_number <- map["season_number"]
    }
    
    public func getImageUrl() -> String? {
        guard let poster_path = poster_path
            else { return nil }
        
        return TMDBUrls.getPosterUrl(forWidth: 72, path: poster_path)
    }
    
    public func getImageCaption() -> String? {
        return name
    }
    
    public func getImageRating() -> Float? {
        return nil
    }
}

public class ShowSeasonResponse: TMDBRecord, ImageProvider {
    var id: Int64?
    var episodes: [ShowEpisode]?
    var name: String?
    var poster_path: String?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        episodes <- map["episodes"]
        name <- map["name"]
        poster_path <- map["poster_path"]
    }
    
    public func getImageUrl() -> String? {
        guard let poster_path = poster_path
            else { return nil }
        
        return TMDBUrls.getPosterUrl(
            forWidth: 72,
            path: poster_path)
    }
    
    public func getImageCaption() -> String? {
        return name
    }
    
    public func getImageRating() -> Float? {
        return nil
    }
}

public class ShowEpisode: TMDBRecord, ImageProvider {
    var id: Int64 = 0
    var air_date: String?
    var name: String?
    var overview: String?
    var vote_average: Float?
    var vote_count: Int64?
    var still_path: String?
    var episode_number: Int?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        air_date <- map["air_date"]
        name <- map["name"]
        overview <- map["overview"]
        vote_average <- map["vote_average"]
        vote_count <- map["vote_count"]
        still_path <- map["still_path"]
        episode_number <- map["episode_number"]
    }
    
    public func getImageUrl() -> String? {
        guard let still_path = still_path
            else { return nil }
        
        return TMDBUrls.getPosterUrl(
            forWidth: 72,
            path: still_path)
    }
    
    public func getImageCaption() -> String? {
        return name
    }
    
    public func getImageRating() -> Float? {
        return vote_average
    }
    
    public func autoButton(into view: UIView)
        -> Media.FavoriteToggler {
        
        FavoriteRecord.setupButton(
            kind: "e",
            type: "tv",
            id: id,
            into: view)
        
        let toggler = Media.FavoriteToggler(
            kind: "e",
            type: "tv",
            media: nil,
            id: id,
            into: view)
        
        return toggler
    }
}
