//
//  AddNewItemView.swift
//  Inventory Manager
//
//  Created by Harsh Bhikadiya on 21/03/24.
//

import SwiftUI
import PhotosUI

struct AddNewItemView: View{
    @ObservedObject var viewModel: InventoryViewModel
    @State var itemName: String = ""
    @State var qty: Int?
    @State var selectedImage : PhotosPickerItem?
    
    @FocusState private var itemNameFocused: Bool
    @FocusState private var qtyFocued: Bool
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            TextField("Item name", text: $itemName )
                .focused($itemNameFocused)
                .onTapGesture { itemNameFocused = true }
                .padding()
                .overlay{
                    RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 1)
                }
            TextField("Quantity", value: $qty, format: .number)
                .focused($qtyFocued)
                .onTapGesture { qtyFocued = true }
                .padding()
                .overlay{
                    RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 1)
                }
            
            Spacer().frame(height: 20)
            HStack{
                PhotosPicker(selection: $viewModel.selectedImage, matching: .images) {
                    VStack{
                        Image(systemName: "photo.on.rectangle.fill").font(.title)
                            .padding()
                            .background{
                                Circle().fill(.white)
                            }
                        Text("Photo")
                    }
                }
                if let photo = viewModel.loadedImage {
                    Spacer().frame(width: 20)
                    Image(uiImage: photo).resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                }
                Spacer()
            }
            
            Spacer().frame(height: 20)
            Button("Add Item") {
                self.viewModel.addNewItem(itemName: self.itemName, itemCount: self.qty, onSuccess : {
                    dismiss()
                })
            }.buttonStyle(BorderedButtonStyle())
            Spacer()
            
        }.padding().background(Color(.secondarySystemFill))
            .navigationTitle("Add a new item")
    }
}

func validate(name : String) {
    
}

#Preview {
    AddNewItemView(viewModel: InventoryViewModel())
}
