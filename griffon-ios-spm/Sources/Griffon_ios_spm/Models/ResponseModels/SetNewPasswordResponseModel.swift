//
//  SetNewPasswordResponseModel.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 28.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct SetNewPasswordResponseModel {
    var message: String
    var status: Int
}


extension SetNewPasswordResponseModel: Decodable {
    private enum SetNewPasswordResponseCodingKeys: String, CodingKey {
        case message
        case status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SetNewPasswordResponseCodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        status = try container.decode(Int.self, forKey: .status)
    }
}
