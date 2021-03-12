//
//  BookViewModel.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 08.03.2021.
//

import Foundation
import Moya
import UIKit

class BookViewModel {
    
    
    
    let bookImageProvider = MoyaProvider<BooksImageService>()
    let bookProvider = MoyaProvider<BookService>()
    
    func getAllBooks(comp: @escaping ([Books])->()){
        bookProvider.request(.getAllBooks) { (result) in
            switch result {
            case .success(let response):
                do {
                    let loadBooks = try JSONDecoder().decode([Books].self, from: response.data)
                    comp(loadBooks)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getImage(path: String, completion: @escaping (Data) -> ()){
        bookImageProvider.request(.getBookImage(path: (path))) { (result) in
            switch result{
            case .success(let response):
                completion(response.data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setBookImage(imagePath: String, bookIV: UIImageView){
        getImage(path: imagePath) { [weak self] (imageData) in
            guard self != nil else { return }
            if let image = UIImage(data: imageData){
                bookIV.image = image
            } else {
                bookIV.image = UIImage(named: "No image")
            }
        }
    }
    
}
