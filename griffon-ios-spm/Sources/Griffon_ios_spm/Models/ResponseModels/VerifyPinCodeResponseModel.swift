//
//  VerifyPinCodeResponseModel.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 28.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct VerifyPinCodeResponseModel {
    public var sid: String // TODO: we need better solution
    var redirectUri: String
}

extension VerifyPinCodeResponseModel: Decodable {
    private enum VerifyPinCodeResponseCodingKeys: String, CodingKey {
        case sid
        case redirectUri = "redirect_uri"
    }
        
    public init(from decoder: Decoder) throws {    
        let container = try decoder.container(keyedBy: VerifyPinCodeResponseCodingKeys.self)
        sid = try container.decode(String.self, forKey: .sid)
        redirectUri = try container.decode(String.self, forKey: .redirectUri)
    }
}
