//
//  FavoriteRecord.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/17/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteRecord: Object {
    @objc dynamic var type_id: String = ""
    
    private static var changeListeners: [Int: () -> Void] = [:]
    private static var nextChangeListenerId: Int = 0
    
    public typealias TypeIdPair = (type: String, id: Int64)
    
    override class func primaryKey() -> String? {
        return "type_id"
    }
    
    func parseKey() -> TypeIdPair? {
        guard let sepOfs = type_id.firstIndex(of: "_")
            else { return nil }
        
        let type = type_id[type_id.startIndex ..< sepOfs]
        let idText = type_id[type_id.index(sepOfs, offsetBy: 1)...]
        
        let result = (
            type: String(type),
            id: Int64(String(idText))
        ) as? FavoriteRecord.TypeIdPair
        
        return result
    }
    
    required init() {
    }

    init(type: String, id: Int64) {
        self.type_id = "\(type)_\(id)"
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
    
    public static func getFavorite(type: String, id: Int64) -> FavoriteRecord? {
        let realm = try! Realm()
        
        let records = realm
            .objects(FavoriteRecord.self)
            .filter("type_id == \"\(type)_\(id)\"")
        
        return records.count > 0 ? records.first : nil
    }
    
    public static func setFavorite(
        type: String,
        id: Int64,
        isFavorite: Bool) {
        
        let realm = try! Realm()
        
        var record: FavoriteRecord?
            
        record = FavoriteRecord.getFavorite(type: type, id: id)
        
        do {
            try realm.write {
                if let existingRecord = record {
                    realm.delete(existingRecord)
                } else {
                    let record = FavoriteRecord(type: type, id: id)
                    realm.add(record)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        notifyChange()
    }
    
    public static func getFavorites() -> [FavoriteRecord] {
        let realm = try! Realm()
        
        let records = realm.objects(FavoriteRecord.self)
        
        var results: [FavoriteRecord] = []
        results.append(contentsOf: records)
        
        return results
    }
    
    public static func setupButton(
        type: String,
        id: Int64,
        into view: UIButton) {
        
        let purple = UIColor(
            red: CGFloat(0x4e) / 255.0,
            green: CGFloat(0x32) / 255.0,
            blue: CGFloat(0x8e) / 255.0,
            alpha: CGFloat(1.0))
        
        view.layer.cornerRadius = 8.0;
        
        if let _ = FavoriteRecord.getFavorite(type: type, id: id) {
            view.backgroundColor = purple
            view.setTitleColor(UIColor.white, for: .normal)
            view.tintColor = UIColor.white
        } else {
            view.backgroundColor = UIColor.clear
            view.setTitleColor(purple, for: .normal)
            view.tintColor = purple
            view.layer.borderWidth = 1.0
            view.layer.borderColor = purple.cgColor
        }
    }
    
    public static func setupButton(
        type: String,
        id: Int64,
        into view: UIImageView) {
        
        view.layer.cornerRadius = 8;
        
        if let _ = FavoriteRecord.getFavorite(type: type, id: id) {
            view.image = UIImage(systemName: "heart.fill")
        } else {
            view.image = UIImage(systemName: "heart")
        }
    }
}


