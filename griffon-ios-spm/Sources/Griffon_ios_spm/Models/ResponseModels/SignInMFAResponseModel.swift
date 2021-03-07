//
//  SignInMFAResponseModel.swift
//  griffon-sdk
//
//  Created by Farabi Bimbetov on 21.09.2020.
//  Copyright © 2020 Dar. All rights reserved.
//

import Foundation

protocol SignInMFAResponseModelProtocol {
    var redirectUri: String { get }
    var sid: String { get }
    var mfaStep: String { get }
    var mfaIdentifier: String { get }
    var addInfo: String { get }
}

public struct SignInMFAResponseModel: SignInMFAResponseModelProtocol {
    public var redirectUri: String
    public var sid: String
    public var mfaStep: String
    public var mfaIdentifier: String
    public var addInfo: String
}


extension SignInMFAResponseModel: Decodable {
    private enum SignInMFAResponseCodingKeys: String, CodingKey {
        case redirectUri = "redirect_uri"
        case sid
        case mfaStep = "mfa_step"
        case mfaIdentifier = "mfa_identifier"
        case addInfo = "add_info"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SignInMFAResponseCodingKeys.self)
        redirectUri = try container.decode(String.self, forKey: .redirectUri)
        sid = try container.decode(String.self, forKey: .sid)
        mfaStep = try container.decode(String.self, forKey: .mfaStep)
        mfaIdentifier = try container.decode(String.self, forKey: .mfaIdentifier)
        addInfo = try container.decode(String.self, forKey: .addInfo)
    }
}
