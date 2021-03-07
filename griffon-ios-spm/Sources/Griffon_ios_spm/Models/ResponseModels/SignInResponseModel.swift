//
//  SignInResponseModel.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 11.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public protocol TokenProtocol {
    var accessToken: String { get }
    var refreshToken: String { get }
    var tokenType: String { get }
    var expiresIn: Int { get }
    var idToken: String { get }
}

public struct SignInResponseModel: TokenProtocol {
    public var accessToken: String
    public var refreshToken: String
    public var tokenType: String
    public var expiresIn: Int
    public var idToken: String
}

extension SignInResponseModel: Decodable {
    private enum SignInResponseCodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case idToken = "id_token"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SignInResponseCodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        idToken = try container.decode(String.self, forKey: .idToken)
    }
    
}
