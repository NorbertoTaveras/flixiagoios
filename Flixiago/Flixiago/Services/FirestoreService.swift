//
//  FirestoreService.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/8/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FirestoreService {
    private static let db = Firestore.firestore()
    private static let auth = Auth.auth()
    
    private static func collectionFrom(
        kind: String,
        type: String) -> String {
        
        let noun: String
        
        switch kind {
        case "w":
            noun = "watched"
            break
            
        case "f":
            noun = "favorite"
            break
            
        case "e":
            noun = "episode"
            break
            
        default:
            fatalError("Unhandled kind \(kind)")
        }
        
        switch type {
        case "tv":
            return "\(noun)_shows"
        case "movie":
            return "\(noun)_movies"
        default:
            fatalError("Unhandled type \(type)")
        }
    }
    
    private static func documentKeyFrom(id: Int64) -> String? {
        guard let uid = auth.currentUser?.uid
            else { return nil }
        
        return "\(id)_\(uid)"
    }
    
    public static func get(
        kind: String,
        type: String,
        id: Int64,
        callback: @escaping (Bool?, Error?) -> Void) {
        
        let collectionName = collectionFrom(
            kind: kind,
            type: type)
        
        let collection = db.collection(collectionName)
        
        guard let idText = documentKeyFrom(id: id)
            else { return }
        
        collection.document(idText).getDocument { (doc, error) in
            guard let data = doc?.data()
                else { callback(nil, nil); return }
            
            guard let watched = data["watched"] as? Bool
                else { callback(nil, nil); return }
            
            callback(watched, nil)
        }
    }
    
    public static func set(
        kind: String,
        type: String,
        media: Media?,
        id: Int64?,
        timestamp: Int64,
        watched: Bool,
        callback: @escaping (Error?) -> Void) {
        
        let collectionName = collectionFrom(
            kind: kind,
            type: type)

        let overview = media?.overview ?? ""
        let poster_path = media?.poster_path ?? ""
        
        let collection = db.collection(collectionName)

        guard let idText = media != nil
            ? documentKeyFrom(id: media!.id)
            : documentKeyFrom(id: id!)
            else { return }
        
        guard let uid = auth.currentUser?.uid
            else { return }
        
        var doc: [String: Any] = [
            "watched": watched,
            "unix_ms": timestamp,
            "uid": uid
        ]
        
        if let media = media {
            doc["id"] = media.id
            doc["overview"] = overview
            doc["poster_path"] = poster_path
            doc["release_date"] = media.formatReleaseDate()
            doc["title"] = media.getTitle()
            doc["vote_average"] = media.vote_average ?? 0.0
        } else {
            doc["id"] = id
        }
        
        collection.document(idText).setData(doc) { error in
            callback(error)
        }
    }

    public static func setWatched(
        kind: String,
        type: String,
        id: Int64,
        timestamp: Int64,
        isFavorite: Bool,
        callback: @escaping (Error?) -> Void) {
        
        let collectionName = collectionFrom(
            kind: kind,
            type: type)
        
        let collection = db.collection(collectionName)
        
        guard let idText = documentKeyFrom(id: id)
            else { return }

        var data: [String: Any] = [
            "watched": isFavorite
        ]
        
        data["unix_ms"] = timestamp
        
        collection.document(idText)
        .updateData(data) { error in
            callback(error)
        }
    }
    
    public static func setWatched(
        movie: Movie,
        timestamp: Int64,
        watched: Bool,
        callback: @escaping (Error?) -> Void) {
        
        set(kind: "w",
            type: "movie",
            media: movie,
            id: nil,
            timestamp: timestamp,
            watched: watched,
            callback: callback)
    }
    
    public static func setWatched(
        show: Show,
        timestamp: Int64,
        watched: Bool,
        callback: @escaping (Error?) -> Void) {

        set(kind: "w",
            type: "tv",
            media: show,
            id: nil,
            timestamp: timestamp,
            watched: watched,
            callback: callback)
    }
    
    public static func setFavorite(
        movie: Movie,
        timestamp: Int64,
        watched: Bool,
        callback: @escaping (Error?) -> Void) {

        set(kind: "f",
            type: "movie",
            media: movie,
            id: nil,
            timestamp: timestamp,
            watched: watched,
            callback: callback)
    }
    
    public static func setFavorite(
        show: Show,
        timestamp: Int64,
        watched: Bool,
        callback: @escaping (Error?) -> Void) {

        set(kind: "f",
            type: "tv",
            media: show,
            id: nil,
            timestamp: timestamp,
            watched: watched,
            callback: callback)
    }
    
    private typealias SyncToDo = (kind: String, type: String)
    
    public static func sync(
        parent: UIViewController,
        callback: @escaping () -> Void) {
        
        var todo: [SyncToDo] = []
        
        for kind in ["e", "w", "f"] {
            for type in ["tv", "movie"] {
                todo.append((
                    kind: kind,
                    type: type
                ))
            }
        }
        
        FirestoreService.runNextSync(
            parent: parent,
            todo: todo,
            index: 0,
            callback: callback)
    }
    
    private static func runNextSync(
        parent: UIViewController,
        todo: [SyncToDo],
        index: Int,
        callback: @escaping () -> Void) {
        
        let current = todo[index]
        
        FirestoreService.sync(
            parent: parent,
            kind: current.kind,
            type: current.type) {
                if index + 1 < todo.count {
                    runNextSync(
                        parent: parent,
                        todo: todo,
                        index: index + 1,
                        callback: callback)
                } else {
                    callback()
                }
        }
    }
    
    private static func sync(
        parent: UIViewController,
        kind: String,
        type: String,
        callback: @escaping () -> Void) {
        
        guard let userId = auth.currentUser?.uid
            else { return }
        
        let removeIndicator = UIUtils.createIndicator(parent: parent)
        
        let collectionName = collectionFrom(
            kind: kind,
            type: type)
        
        let collection = db.collection(collectionName)
        
        let unixMs: Int64
        
        if let syncInfo = SyncInfoRecord.getTimestamp(
            kind: kind,
            type: type) {
            
            unixMs = syncInfo.timestamp
        } else {
            // There is no sync info record
            // want all remote records
            unixMs = 0
        }
        
        print("Syncing records updated since \(unixMs)")
        
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        
        var firstError: Error?
        
        var pending = 0
        var completed = 0
        
        let handleCompletion = {
            completed += 1
            print("\(kind)_\(type) completed \(completed) of \(pending)")
            if completed == pending {
                removeIndicator()
                callback()
            }
        }
        
        // Find all of the records on firebase
        // that are newer than the records in the local database
        pending += 1
        collection
            .whereField("unix_ms", isGreaterThan: unixMs)
            .whereField("uid", isEqualTo: userId)
            .getDocuments { (docs, error) in
                print("Found \(docs?.documents.count ?? 0) documents")
                
                for doc in docs?.documents ?? [] {
                    let data = doc.data()
                    
                    guard let id = data["id"] as? Int64,
                        let remoteTimestamp = data["unix_ms"] as? Int64,
                        let remoteWatched = data["watched"] as? Bool
                        else { continue }
                    
                    var localRecord = FavoriteRecord.get(
                        kind: kind,
                        type: type,
                        id: id)
                    
                    // If we don't have a local record, or,
                    // the local record is older than the remote record
                    if localRecord == nil ||
                        localRecord!.timestamp < remoteTimestamp {
                        
                        // Update the local record using the information
                        // in the remte record
                        localRecord = FavoriteRecord.set(
                            kind: kind,
                            type: type,
                            id: id,
                            isFavorite: remoteWatched,
                            timestamp: remoteTimestamp)
                    } else if localRecord != nil &&
                        localRecord!.timestamp > remoteTimestamp {
                        
                        // Update the remote record using the information
                        // in the local record
                        pending += 1
                        FirestoreService.setWatched(
                            kind: kind,
                            type: type,
                            id: id,
                            timestamp: localRecord!.timestamp,
                            isFavorite: localRecord!.favorite) {
                                (error) in
                                handleCompletion()
                                if firstError == nil {
                                    firstError = error
                                }
                        }
                    }
                }
                
                if let error = SyncInfoRecord.setTimestamp(
                    kind: kind,
                    type: type,
                    timestamp: now) {
                    print(error)
                }
                
                handleCompletion()
        }
        
        // Find all of the local records
        // that are newer than the records in firebase
        let records = FavoriteRecord.get(
            kind: kind,
            type: type,
            since: unixMs)

        firstError = nil
        
        for record in records {
            guard let info = record.parseKey()
                else { continue }
            
            pending += 1
            FirestoreService.get(
                kind: kind,
                type: type,
                id: info.id) { (isFavorite, error) in
                    if isFavorite == nil {
                        pending += 1
                        TMDBService.getMediaDetail(
                            id: info.id,
                            type: type) { (media, error) in
                                guard let media = media
                                    else { return }
                                
                                pending += 1
                                FirestoreService.set(
                                    kind: kind,
                                    type: type,
                                    media: media,
                                    id: nil,
                                    timestamp: record.timestamp,
                                    watched: record.favorite) { (error) in
                                        handleCompletion()
                                        if firstError == nil {
                                            firstError = error
                                        }
                                }
                                
                                handleCompletion()
                        }
                    } else {
                        pending += 1
                        FirestoreService.setWatched(
                            kind: kind,
                            type: type,
                            id: info.id,
                            timestamp: record.timestamp,
                            isFavorite: record.favorite) { (error) in
                                handleCompletion()
                                if firstError != nil {
                                    firstError = error
                                }
                        }
                    }
                    
                    handleCompletion()
            }
        }
    }
}
