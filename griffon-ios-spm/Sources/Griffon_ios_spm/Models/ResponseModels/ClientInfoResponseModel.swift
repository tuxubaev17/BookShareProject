//
//  ClientInfoResponseModel.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 06.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation


public struct ClientInfoResponseModel {
    //var id: String
    var secret: String
    var termsConditionUrl: String?
    var signUpType: [SignUpType]
    var buttonColor: ButtonColor
    var logoImage: String
    var backgroundColor: String
    
    public func getTermsConditionUrl() -> String {
        return self.termsConditionUrl ?? ""
    }
}

extension ClientInfoResponseModel: Decodable {
    
    private enum ClientInfoResponseCodingKeys: String, CodingKey {
        //case id
        case secret = "client_secret"
        case termsConditionUrl = "terms_condition_url"
        case signUpType = "sign_up_type"
        case buttonColor = "button_color"
        case logoImage = "logo_image"
        case backgroundColor = "background_color"
    }
    
    public init(from decoder: Decoder ) throws {
        let container = try decoder.container(keyedBy: ClientInfoResponseCodingKeys.self)
        //id = try container.decode(String.self, forKey: .id)
        secret = try container.decode(String.self, forKey: .secret)        
        termsConditionUrl = try? container.decode(String.self, forKey: .termsConditionUrl)
        signUpType = try container.decode([SignUpType].self, forKey: .signUpType)
        buttonColor = try container.decode(ButtonColor.self, forKey: .buttonColor)
        logoImage = try container.decode(String.self, forKey: .logoImage)
        backgroundColor = try container.decode(String.self, forKey: .backgroundColor)
    }
}

public enum SignUpType: String, Decodable {
    case email
    case phone_number
}
