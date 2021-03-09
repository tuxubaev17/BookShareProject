//
//  BookViewModel.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 08.03.2021.
//

import Foundation
import Moya

class BookViewModel {
    
    let bookImageProvider = MoyaProvider<BooksImageService>()
    
    public func getImage(path: String, completion: @escaping (Data) -> ()){
        bookImageProvider.request(.getBookImage(path: (path))) { (result) in
            switch result{
            case .success(let response):
                completion(response.data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
