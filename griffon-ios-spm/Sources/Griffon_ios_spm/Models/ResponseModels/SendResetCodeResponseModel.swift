//
//  SendResetCodeResponseModel.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 25.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct SendResetCodeResponseModel {
    var message: String
    var addInfo: String
    var status: Int
    var sid: String
}

extension SendResetCodeResponseModel: Decodable {
    
    private enum SendResetCodeResponseCodingKeys: String, CodingKey {
        case message
        case addInfo = "add_info"
        case status
        case sid
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SendResetCodeResponseCodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        addInfo = try container.decode(String.self, forKey: .addInfo)
        status = try container.decode(Int.self, forKey: .status)
        sid = try container.decode(String.self, forKey: .sid)
    }
}
