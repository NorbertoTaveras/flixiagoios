//
//  FavoriteRecord.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/17/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import RealmSwift

public class FavoriteRecord: Object {
    @objc dynamic var kind_type_id: String = ""
    @objc dynamic var favorite: Bool = true
    @objc dynamic var timestamp: Int64 = 0
    
    private static var changeListeners: [Int: () -> Void] = [:]
    private static var nextChangeListenerId: Int = 0
    
    public typealias KindTypeId = (
        kind: String,
        type: String,
        id: Int64
    )
    
    override public class func primaryKey() -> String? {
        return "kind_type_id"
    }
    
    func parseKey() -> KindTypeId? {
        guard let kindSepOfs = kind_type_id.firstIndex(of: "_")
            else { return nil }
        
        let kind = kind_type_id[kind_type_id.startIndex ..< kindSepOfs]
        
        let type_id = kind_type_id[kind_type_id.index(kindSepOfs, offsetBy: 1)...]
        
        guard let idSepOfs = type_id.firstIndex(of: "_")
            else { return nil }
        
        let type = type_id[type_id.startIndex ..< idSepOfs]
        
        let idText = type_id[type_id.index(idSepOfs, offsetBy: 1)...]
        
        let result = (
            kind: String(kind),
            type: String(type),
            id: Int64(String(idText))
        ) as? FavoriteRecord.KindTypeId
        
        return result
    }
    
    required init() {
        super.init()
    }
    
    init(kind: String, type: String, id: Int64, isFavorite: Bool) {
        self.kind_type_id = "\(kind)_\(type)_\(id)"
        self.favorite = isFavorite
        self.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
    }

    public static func startListeningForChanges(
        callback: @escaping () -> Void) -> Int {
        
        let listenerId = nextChangeListenerId
        nextChangeListenerId += 1
        
        changeListeners[listenerId] = callback
        
        return listenerId
    }
    
    public static func stopListeningForChanges(id: Int) {
        changeListeners[id] = nil
    }
    
    private static func notifyChange() {
        for listener in changeListeners {
            listener.value()
        }
    }
    
    @discardableResult
    public static func toggle(
        kind: String,
        type: String,
        id: Int64,
        into view: UIView) -> FavoriteRecord? {
        
        let record = FavoriteRecord.get(
            kind: kind,
            type: type,
            id: id)
        
        let wasFavorite = record?.favorite ?? false
        
        let updatedRecord = FavoriteRecord.set(
            kind: kind,
            type: type,
            id: id,
            isFavorite: !wasFavorite)
        
        if let button = view as? UIButton {
            setupButton(
                kind: kind,
                type: type,
                record: updatedRecord,
                into: button)
        } else if let imageView = view as? UIImageView {
            setupButton(
                kind: kind,
                type: type,
                record: updatedRecord,
                into: imageView)
        } else {
            fatalError("Unhandled view type")
        }
        
        
        if let record = updatedRecord {
            FirestoreService.set(
                kind: kind,
                type: type,
                media: nil,
                id: id,
                timestamp: record.timestamp,
                watched: !wasFavorite) { (error) in
                    if error != nil {
                        print(error as Any)
                    }
            }
        }

        
        return updatedRecord
    }
    
    public static func getFavorite(
        type: String,
        id: Int64) -> FavoriteRecord? {
        
        return get(
            kind: "f",
            type: type,
            id: id)
    }
    
    public static func getWatch(
        type: String,
        id: Int64) -> FavoriteRecord? {
        
        return get(
            kind: "w",
            type: type,
            id: id)
    }
    
    public static func setFavorite(
        type: String,
        id: Int64,
        isFavorite: Bool) -> FavoriteRecord? {
        
        return set(
            kind: "f",
            type: type,
            id: id,
            isFavorite: isFavorite)
    }
    
    public static func setWatch(
        type: String,
        id: Int64,
        isFavorite: Bool) -> FavoriteRecord? {
        
        return set(
            kind: "w",
            type: type,
            id: id,
            isFavorite: isFavorite)
    }

    public static func set(
        kind: String,
        type: String,
        id: Int64,
        isFavorite: Bool) -> FavoriteRecord? {
        
        return set(kind: kind,
            type: type,
            id: id,
            isFavorite: isFavorite,
            timestamp: nil)
    }
    
    public static func set(
        kind: String,
        type: String,
        id: Int64,
        isFavorite: Bool,
        timestamp: Int64?) -> FavoriteRecord? {
        
        let realm = try! Realm()
        
        var record: FavoriteRecord?
            
        record = FavoriteRecord.get(
            kind: kind,
            type: type,
            id: id)
        
        do {
            try realm.write {
                if let existingRecord = record {
                    realm.delete(existingRecord)
                }
                
                record = FavoriteRecord(
                    kind: kind,
                    type: type,
                    id: id,
                    isFavorite: isFavorite)
                
                if let record = record {
                    if timestamp != nil {
                        record.timestamp =
                            Int64(Date().timeIntervalSince1970 * 1000)
                    }
                    
                    realm.add(record)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        notifyChange()
        
        return record
    }
    
    public static func get(
        kind: String,
        type: String,
        since: Int64) -> [FavoriteRecord] {
        
        let realm = try! Realm()
        
        let records = realm.objects(FavoriteRecord.self)
            .filter("kind_type_id BEGINSWITH \"\(kind)_\(type)\"" +
                " && timestamp > \(since)")
            .sorted(byKeyPath: "timestamp",
                    ascending: false)
        
        var results: [FavoriteRecord] = []
        results.append(contentsOf: records)
        
        return results
    }
    
    public static func getFavorites(onlyFavorite: Bool) -> [FavoriteRecord] {
        return get(kind: "f",
                   onlyFavorite: onlyFavorite)
    }
    
    public static func getWatches(onlyFavorite: Bool) -> [FavoriteRecord] {
        return get(kind: "w",
                   onlyFavorite: onlyFavorite)
    }

    public static func get(kind: String, onlyFavorite: Bool) -> [FavoriteRecord] {
        let realm = try! Realm()
        
        var records = realm.objects(FavoriteRecord.self)
            .filter("kind_type_id BEGINSWITH \"\(kind)_\"")
        
        if onlyFavorite {
            records = records.filter("favorite != false")
        }
        
        var results: [FavoriteRecord] = []
        results.append(contentsOf: records)
        
        return results
    }
    
    public static func get(
        kind: String,
        type: String,
        id: Int64) -> FavoriteRecord? {
        let realm = try! Realm()
        
        let records = realm.objects(FavoriteRecord.self)
            .filter("kind_type_id == \"\(kind)_\(type)_\(id)\"")
        
        return records.first
    }
    
    public static func setupFavoriteButton(
        type: String,
        id: Int64,
        into view: UIView) -> FavoriteRecord? {
        
        return setupButton(
            kind: "f",
            type: type,
            id: id,
            into: view)
    }
    
    public static func setupWatchButton(
        type: String,
        id: Int64,
        into view: UIView) -> FavoriteRecord? {
        
        return setupButton(
            kind: "w",
            type: type,
            id: id,
            into: view)
    }
    
    @discardableResult
    public static func setupButton(
        kind: String,
        type: String,
        id: Int64,
        into view: UIView) -> FavoriteRecord? {
        let record = FavoriteRecord.get(
            kind: kind,
            type: type,
            id: id)
        
        setupButton(
            kind: kind,
            type: type,
            record: record,
            into: view)
        
        return record
    }
    
    public static func setupButton(
        kind: String,
        type: String,
        record: FavoriteRecord?,
        into view: UIView) {
        
        let color: UIColor
        
        if kind != "e" {
            color = UIUtils.purple
        } else {
            color = UIUtils.yellow
        }
        
        view.layer.cornerRadius = 8.0;
        
        let button: UIButton? = view as? UIButton
        let image: UIImageView? = view as? UIImageView

        button?.layer.borderWidth = 1.0
        button?.layer.borderColor = color.cgColor
        
        let icons = iconsFrom(kind: kind)

        if record?.favorite ?? false {
            image?.image = UIImage(systemName: icons[1])
            button?.tintColor = UIColor.white
            button?.backgroundColor = color
            button?.setTitleColor(UIColor.white, for: .normal)
        } else {
            image?.image = UIImage(systemName: icons[0])
            button?.tintColor = color
            button?.backgroundColor = UIColor.clear
            button?.setTitleColor(color, for: .normal)
        }
    }
    
    private static func iconsFrom(kind: String) -> [String] {
        switch kind {
        case "f":
            return [
                "heart",
                "heart.fill"
            ]
            
        case "w":
            return [
                "eye",
                "eye.fill"
            ]
            
        case "e":
            return [
                "eye",
                "eye.fill"
            ]
            
        default:
            fatalError("Unhandled kind")
        }
    }
    
    public static func setupFavoriteButton(
        type: String,
        id: Int64,
        into view: UIImageView) -> FavoriteRecord? {
        
        return setupButton(
            kind: "f",
            type: type,
            id: id,
            into: view)
    }
    
    public static func setupWatchButton(
        type: String,
        id: Int64,
        into view: UIImageView) -> FavoriteRecord? {
        
        return setupButton(
            kind: "w",
            type: type,
            id: id,
            into: view)
    }

    @discardableResult
    public static func setupButton(
        kind: String,
        type: String,
        id: Int64,
        into view: UIImageView) -> FavoriteRecord? {
        
        view.layer.cornerRadius = 8;
        
        let icons = iconsFrom(kind: kind)
        
        let record = FavoriteRecord.get(
            kind: kind,
            type: type,
            id: id)
        
        if record?.favorite ?? false {
            view.image = UIImage(systemName: icons[1])
        } else {
            view.image = UIImage(systemName: icons[0])
        }
        
        return record
    }
}


