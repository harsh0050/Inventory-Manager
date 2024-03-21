//
//  InventoryItem.swift
//  Inventory Manager
//
//  Created by Harsh Bhikadiya on 20/03/24.
//

import Foundation
import RealmSwift

class InventoryItem : Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var itemName: String = ""
    @Persisted var itemImageUrl: String = ""
    @Persisted var itemCount: Int = 0
    
    convenience init(itemName: String, itemImageUrl: String, itemCount: Int) {
        self.init()
        self.itemName = itemName
        self.itemImageUrl = itemImageUrl
        self.itemCount = itemCount
    }
}
