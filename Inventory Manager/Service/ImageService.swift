//
//  ImageService.swift
//  Inventory Manager
//
//  Created by Harsh Bhikadiya on 20/03/24.
//

import Foundation
import PhotosUI
import SwiftUI

class ImageService{
    func saveImage(item: PhotosPickerItem, completionHandler: @escaping (_ result: Result<String, Error>) -> Void){
        Task {
            switch await getImageAsData(item){
                
            case .success(let data):
                if let contentType = item.supportedContentTypes.first {
                    let fileName = "\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")"
                    let url = self.getDocumentDirectory().appending(path: fileName, directoryHint: .notDirectory)
                    
                    do{
                        try data.write(to: url)
                        completionHandler(.success(url.absoluteString))
                    }catch let error as NSError{
                        completionHandler(.failure(error))
                    }
                    
                }
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func getImageAsData(_ selectedImage: PhotosPickerItem) async -> Result<Data, Error> {
        do{
            if let data = try await selectedImage.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    return .success(data)
                }else{
                    return .failure(MyError.imageDataConversionError)
                }
            }else{
                return .failure(MyError.nilDataError)
            }
        }catch let error {
            return .failure(error)
        }
    }
    
    enum MyError: Error{
        case imageDataConversionError
        case nilDataError
    }
}
