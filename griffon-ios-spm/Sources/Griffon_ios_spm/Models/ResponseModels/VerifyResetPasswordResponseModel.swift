//
//  VerifyResetPasswordResponseModel.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 28.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct VerifyResetPasswordResponseModel {
    var message: String
    var status: Int
}

extension VerifyResetPasswordResponseModel: Decodable {
    private enum VerifyResetPasswordResponseCodingKeys: String, CodingKey {
        case message
        case status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: VerifyResetPasswordResponseCodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        status = try container.decode(Int.self, forKey: .status)
    }
}

