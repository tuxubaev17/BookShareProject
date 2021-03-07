//
//  UserProfilesResponseModel.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 02.09.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct UserProfilesResponseModel {
    public var id: String
    public var bucketId: String
    public var phoneNumber: String?
    public var phoneNumberVerified: Bool?
    public var email: String?
    public var emailVerified: String?
    public var mfaType: String
    public var avatar: UserProfileAvatar
}

extension UserProfilesResponseModel: Decodable {
    
    private enum UserProfilesResponseCodingKeys: String, CodingKey {
        case id
        case bucketId = "bucket_id"
        case phoneNumber = "phone_number"
        case phoneNumberVerified = "phone_number_verified"
        case email
        case emailVerified = "email_verified"
        case mfaType = "mfa_type"
        case avatar
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserProfilesResponseCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        bucketId = try container.decode(String.self, forKey: .bucketId)        
        phoneNumber = try? container.decode(String.self, forKey: .phoneNumber)
        phoneNumberVerified = try? container.decode(Bool.self, forKey: .phoneNumberVerified)
        email = try? container.decode(String.self, forKey: .email)
        emailVerified = try? container.decode(String.self, forKey: .emailVerified)
        mfaType = try container.decode(String.self, forKey: .mfaType)
        avatar = try container.decode(UserProfileAvatar.self, forKey: .avatar)
    }
}

public struct UserProfileAvatar: Decodable {
    public var original: String
    public var normal: String
    public var thumbnail: String
}
