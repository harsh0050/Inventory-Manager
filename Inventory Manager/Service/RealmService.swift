//
//  RealmService.swift
//  Inventory Manager
//
//  Created by Harsh Bhikadiya on 20/03/24.
//

import Foundation
import RealmSwift

class RealmService{
    private let realm = try! Realm()
    
    private var notificationToken: NotificationToken?
    
    func addNewItem(_ item: InventoryItem){
        try? realm.write {
            realm.add(item)
        }
    }
    
    func updateItemCount(item: InventoryItem, newCount: Int){
        try? realm.write {
            item.itemCount = newCount
        }
    }
    
    func deleteItem(_ item: InventoryItem){
        try? realm.write {
            realm.delete(item)
        }
    }
    
    func observeInventory(callback: @escaping (RealmCollectionChange<Results<InventoryItem>>) -> Void){
        let query = realm.objects(InventoryItem.self)
        
        notificationToken = query.observe{ (changes) in
            callback(changes)
        }
    }
    
    func stopObservingInventory(){
        notificationToken?.invalidate()
    }
}
