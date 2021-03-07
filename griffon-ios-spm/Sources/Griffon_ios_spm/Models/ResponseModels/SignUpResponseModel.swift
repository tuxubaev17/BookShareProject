//
//  SignUpResponseModel.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 03.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct SignUpResponseModel: TokenProtocol {
    public var accessToken: String
    public var expiresIn: Int
    public var idToken: String
    public var redirectUri: String
    public var refreshToken: String
    public var sid: String
    public var tokenType: String
}

extension SignUpResponseModel: Decodable {
    
    private enum SignUpResponseCodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case idToken = "id_token"
        case redirectUri = "redirect_uri"
        case refreshToken = "refresh_token"
        case sid
        case tokenType = "token_type"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SignUpResponseCodingKeys.self)
        
        accessToken = try container.decode(String.self, forKey: .accessToken)
        expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        idToken = try container.decode(String.self, forKey: .idToken)
        redirectUri = try container.decode(String.self, forKey: .redirectUri)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        sid = try container.decode(String.self, forKey: .sid)
        tokenType = try container.decode(String.self, forKey: .tokenType)
    }
}
