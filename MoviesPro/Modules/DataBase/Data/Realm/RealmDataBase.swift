//
//  RealmDataBase.swift
//  MoviesPro
//
//  Created by Boris Zverik on 20.05.2024.
//

import RealmSwift

protocol RepositoryDataBase {
    associatedtype Model: Object
    func get<T: Model>(_ object: [Model]) -> [Model]
    func save<T: Model>(_ object: [Model])
    func delete<T: Model>(_ object: Model)
}

final class RealmDataBase: RepositoryDataBase {
    func get<T: Object>(_ object: [T]) -> [T] {
        do {
            let realm = try Realm()
            let realmObjects = realm.objects(T.self)
            var entityArray: [T] = []
            realmObjects.forEach {
                entityArray.append($0)
            }
            return entityArray
        } catch {
            debugPrint(error.localizedDescription)
            return []
        }
    }
    
    func save<T: Object>(_ object: [T]) {
        do {
            let configuration = Realm.Configuration.defaultConfiguration
            let realm = try Realm(configuration: configuration)
            try realm.write { realm.add(object) }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            let realm = try Realm(configuration: configuration)
            try realm.write { realm.delete(object) }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

