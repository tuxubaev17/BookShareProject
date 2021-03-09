//
//  BooksImageService.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 09.03.2021.
//

import Foundation
import Moya

enum BooksImageService {
    case getBookImage(path: String)
}

extension BooksImageService: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://dev-darmedia-uploads.s3.eu-west-1.amazonaws.com")!
    }
    
    var path: String {
        switch self {
        case .getBookImage(let path):
            return "/\(path)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getBookImage:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task{
        return .requestParameters(parameters: [:], encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return ["Content-Type":"application/json"]
    }
}
