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
    case getRentId(rentId: Int)
}

extension BookService: TargetType {
    var baseURL: URL {
        return URL(string: "https://dar-library.dar-dev.zone/api")!
    }
    
    var path: String {
        switch self {
        case .getAllBooks:
            return "/books"
        case .getRentId(let rentId):
            return "/rent/\(rentId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllBooks, .getRentId:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getAllBooks, .getRentId:
            return Data()
        }
    }
    
    var task: Task {
        return .requestParameters(parameters: [:], encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return ["Content-Type":"application/json"]
    }
    
    
}
