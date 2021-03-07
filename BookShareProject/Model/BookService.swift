//
//  BookService.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 07.03.2021.
//

import Foundation
import Moya


enum BookService {
    case getAllBooks
    case deleteBook(id: Int)
}

extension BookService: TargetType {
    var baseURL: URL {
        return URL(string: "https://dar-library.dar-dev.zone/api")!
    }
    
    var path: String {
        switch self {
        case .getAllBooks:
            return "/books"
        case .deleteBook(let id):
            return "/books/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllBooks:
            return .get
        case .deleteBook(_ ):
            return .delete
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getAllBooks:
            return Data()
        case .deleteBook(let id):
            return "{'id':'\(id)'}".data(using: .utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .getAllBooks, .deleteBook(_):
                return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type":"application/json"]
    }
    
    
}
