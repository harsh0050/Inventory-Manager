//
//  InventoryViewModel.swift
//  Inventory Manager
//
//  Created by Harsh Bhikadiya on 20/03/24.
//

import Foundation
import PhotosUI
import SwiftUI
import RealmSwift

class InventoryViewModel: ObservableObject{
    @Published var isLoading = false
    @Published var inventoryItems = [InventoryItem]()
    @Published var selectedImage : PhotosPickerItem? = nil {
        didSet{
            if(selectedImage == nil){
                return
            }
            self.loadImage()
        }
    }
    
    @Published var loadedImage: UIImage?
    
    var liveData : Results<InventoryItem>?
    
    let realmService: RealmService = RealmService()
    let imageService: ImageService = ImageService()
    
    init(){
        realmService.observeInventory { (changes) in
            switch changes {
                
            case .initial(let items):
                self.liveData = items
                self.inventoryItems.append(contentsOf: self.liveData!)
                items.forEach{item in
                    print(item.itemImageUrl)
                }
                
            case .update(_, let deletions, let insertions, let modifications):
                deletions.forEach{i in self.inventoryItems.remove(at: i)}
                insertions.forEach{i in
                    self.inventoryItems.append(self.liveData![i])
                }
                modifications.forEach{i in
                    self.inventoryItems[i] = self.liveData![i]
                }
                
            case .error(let error):
                print("\(error)")
            }
        }
    }
    
    func addItem(itemName: String, itemCount: Int){
        if let photo = selectedImage {
            addNewItem(itemName: itemName, itemCount: itemCount, itemPhoto: photo)
        }
    }
    
    private func addNewItem(itemName: String, itemCount: Int, itemPhoto: PhotosPickerItem){
        isLoading = true
        imageService.saveImage(item: itemPhoto) { result in
            switch result {
                
            case .success(let url):
                self.realmService.addNewItem(InventoryItem(itemName: itemName, itemImageUrl: url, itemCount: itemCount))
                self.isLoading = false
                
                
            case .failure(let error):
                //TODO ("update ui to display error")
                print("Error in saving image to storage. \(error)")
                self.isLoading = false
            }
        }
    }
    
    func incrementItemCount(item: InventoryItem){
        setItemCount(item: item, newItemCount: item.itemCount + 1)
    }
    
    func decrementItemCount(item: InventoryItem){
        setItemCount(item: item, newItemCount: item.itemCount - 1)
    }
    
    func setItemCount(item: InventoryItem, newItemCount: Int){
        if(newItemCount >= 0){
            realmService.updateItemCount(item: item, newCount: newItemCount)
        }
    }
    
    private func loadImage() {
        guard let selectedImage = selectedImage else{
            print("No image selected.")
            return
        }
        Task{
            switch await imageService.getImageAsData(selectedImage){
                
            case .success(let data):
                self.loadedImage = UIImage(data: data)
                
            case .failure(let error):
                print("\(error)")
            }
            
        }
    }
    
    func addNewItem(itemName: String, itemCount: Int?, onSuccess: @escaping () -> Void){
        guard !itemName.isEmpty else{
            print("No name.")
            return
        }
        guard let itemCount = itemCount else{
            print("itemCount null")
            return
        }
        guard let selectedImage = selectedImage else{
            //TODO
            print("No image Selected.")
            return
        }
        imageService.saveImage(item: selectedImage) { result in
            switch result {
                
            case .success(let url):
                let item = InventoryItem(itemName: itemName, itemImageUrl: url, itemCount: itemCount)
                DispatchQueue.main.async {
                    self.realmService.addNewItem(item)
                    self.selectedImage = nil
                    self.loadedImage = nil
                    onSuccess()
                }
            case .failure(let error):
                //TODO
                print("failed to save. \(error)")
            }
        }
    }
}
