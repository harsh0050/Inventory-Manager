//
//  InventoryHomeView.swift
//  Inventory Manager
//
//  Created by Harsh Bhikadiya on 20/03/24.
//

import SwiftUI
import PhotosUI

struct InventoryHomeView: View {
    let columns = [GridItem(.adaptive(minimum: 150))]
    @StateObject var viewModel = InventoryViewModel()
    @State var navigationPath : NavigationPath = .init()
    @State var searchQuery: String = ""
    
    var body: some View {
        NavigationStack(path: $navigationPath){
            ScrollView{
                LazyVGrid(columns: self.columns){
                    ForEach(searchResults){item in
                        InventoryItemView(
                            item: item,
                            onClickIncrementButton: {
                                viewModel.incrementItemCount(item: item)
                            },
                            onClickDecrementButton: {
                                viewModel.decrementItemCount(item: item)
                            },
                            onSetQuantity: {newQty in
                                viewModel.setItemCount(item: item, newItemCount: newQty)
                            }
                        )
                    }
                }
            }.padding(10)
                .navigationTitle("Home")
                .toolbar{
                    NavigationLink {
                        AddNewItemView(viewModel: self.viewModel)
                    } label: {
                        Image(systemName: "plus")
                    }
                }.searchable(text: $searchQuery, prompt: "Search Item")
        }
        
    }
    
    var searchResults: [InventoryItem] {
        if(searchQuery.isEmpty){
            return viewModel.inventoryItems
        }else{
            return viewModel.inventoryItems.filter{ item in
                return item.itemName.starts(with: searchQuery)
            }
        }
    }
}


struct InventoryItemView: View{
    @State var item: InventoryItem
    @State var isSetQuantityAlertShown: Bool = false
    @State var alertNewQuantity : Int?
    
    let onClickIncrementButton: () -> Void
    let onClickDecrementButton: () -> Void
    let onSetQuantity: (Int) -> Void
    
    var body: some View{
        
        VStack{
            AsyncImage(url: URL(string: item.itemImageUrl)){image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                
                Text("Image has been removed.").frame(height: 100).padding().background(.white).aspectRatio(contentMode: .fill)
            }
            Spacer().frame(height: 10)
            Text(item.itemName).fontWeight(.bold).foregroundStyle(.white)
            Spacer().frame(height: 10)
            HStack{
                Button {
                    onClickDecrementButton()
                } label: {
                    Image(systemName: "minus")
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                Button(String(item.itemCount)){
                    isSetQuantityAlertShown = true
                }
                .foregroundStyle(.white)
                .alert("Set Quantity", isPresented: $isSetQuantityAlertShown) {
                    TextField("Quantity", value: $alertNewQuantity, format: .number)
                    Button("OK"){
                        onSetQuantity(alertNewQuantity!)
                    }
                }.onAppear{
                    self.alertNewQuantity = self.item.itemCount
                }
                
                Spacer()
                
                Button {
                    onClickIncrementButton()
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.blue)
                }
            }
            .padding(5)
            .overlay{
                RoundedRectangle(cornerRadius: 5).stroke(.blue, lineWidth: 1)
            }
        }
        .padding(15)
        .background(.card).clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
    
}

#Preview{
    InventoryItemView(
        item: InventoryItem(
            itemName: "Lays",
            itemImageUrl: "https://www.lays.com/sites/lays.com/files/2022-05/XL%20Lays%20Flamin%20Hot%20New.png",
            itemCount: 34
        ), onClickIncrementButton: {},
        onClickDecrementButton: {},
        onSetQuantity: {i in}
    )
}

#Preview {
    InventoryHomeView()
}
