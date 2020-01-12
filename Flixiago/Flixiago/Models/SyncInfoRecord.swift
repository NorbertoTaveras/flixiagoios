//
//  SyncInfoRecord.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/8/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import Foundation
import RealmSwift

class SyncInfoRecord: Object {
    @objc dynamic var kind_type: String = ""
    @objc dynamic var timestamp: Int64 = 0
    
    public typealias KindType = (
        kind: String,
        type: String
    )
    
    override class func primaryKey() -> String? {
        return "kind_type"
    }
    
    required init() {
        super.init()
    }
    
    convenience init(kind: String, type: String, timestamp: Int64) {
        self.init()
        self.kind_type = SyncInfoRecord.makePrimaryKey(
            kind: kind,
            type: type)
        self.timestamp = timestamp
    }
    
    static func makePrimaryKey(kind: String, type: String) -> String {
        return "\(kind)_\(type)"
    }
    
    static func getTimestamp(
        kind: String,
        type: String)
        -> SyncInfoRecord? {
        
        let realm = try! Realm()
        
        let key = makePrimaryKey(
            kind: kind,
            type: type)
            
        let records = realm.objects(SyncInfoRecord.self)
            .filter("kind_type = \"\(key)\"")
        
        return records.first
    }
    
    static func setTimestamp(
        kind: String,
        type: String,
        timestamp: Int64) -> Error? {
        
        let record = getTimestamp(kind: kind, type: type)
        
        let realm = try! Realm()
        
        do {
            try realm.write {
                if let record = record {
                    record.timestamp = timestamp
                } else {
                    let newRecord = SyncInfoRecord(
                        kind: kind,
                        type: type,
                        timestamp: timestamp)
                    
                    realm.add(newRecord)
                }
            }
        } catch {
            return error
        }
        
        return nil
    }
}
