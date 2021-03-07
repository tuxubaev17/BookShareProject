//
//  SignUpWithPhoneResponseModel.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 05.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct SignUpWithPhoneResponseModel {
    public var sid: String // TODO: we need better solution
    var redirectUri: String
    var addInfo: String
}

extension SignUpWithPhoneResponseModel: Decodable {
    private enum SignUpWithPhoneResponseCodingKeys: String, CodingKey {
        case sid
        case redirectUri = "redirect_uri"
        case addInfo = "add_info"
    }
        
    public init(from decoder: Decoder) throws {
    
        let container = try decoder.container(keyedBy: SignUpWithPhoneResponseCodingKeys.self)
        sid = try container.decode(String.self, forKey: .sid)
        redirectUri = try container.decode(String.self, forKey: .redirectUri)
        addInfo = try container.decode(String.self, forKey: .addInfo)
    }
}
