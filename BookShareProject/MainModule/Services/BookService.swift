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
}

extension BookService: TargetType {
    var baseURL: URL {
        return URL(string: "https://dar-library.dar-dev.zone/api")!
    }
    
    var path: String {
        switch self {
        case .getAllBooks:
            return "/books"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllBooks:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getAllBooks:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .getAllBooks:
                return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type":"application/json"]
    }
    
    
}
