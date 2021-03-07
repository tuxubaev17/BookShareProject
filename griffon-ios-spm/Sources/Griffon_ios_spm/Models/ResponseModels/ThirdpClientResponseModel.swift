//
//  ThirdpClientResponseModel.swift
//  griffon-sdk
//
//  Created by Farabi Bimbetov on 11.09.2020.
//  Copyright © 2020 Dar. All rights reserved.
//

import Foundation

public struct ThirdpClientResponseModel {
    var provider: String
    var clientId: String
    var clientSecret: String
    var bucket: String
    var isDisabled: Bool
}

extension ThirdpClientResponseModel: Decodable {
    
    private enum ThirdpClientResponseCodingKeys: String, CodingKey {
        case bucket
        case provider
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case isDisabled = "is_disabled"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ThirdpClientResponseCodingKeys.self)
        bucket = try container.decode(String.self, forKey: .bucket)
        provider = try container.decode(String.self, forKey: .provider)
        clientId = try container.decode(String.self, forKey: .clientId)
        clientSecret = try container.decode(String.self, forKey: .clientSecret)
        isDisabled = try container.decode(Bool.self, forKey: .isDisabled)
    }
}

