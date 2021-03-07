//
//  Constants.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 7/17/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import Foundation
import KeychainSwift

public class GriffonConfigurations: ApiConfiguration {
    public var clientId: String = "griffon"
    public var brand: String = "griffon"
    public var bucket: String = "griffon"
    
    public var clientSecret: String = #"""
$2a$10$qC9dtMHqvgbA/Rn10UV49OY4Lp6yETBsNKPTAdp4mnQcVL/.bDbQS
"""#
    public var url: String  = "https://griffon.dar-dev.zone/api/v1"
    public var clientInfo: ClientInfoResponseModel?
    
    public init(clientId: String,
                brand: String,
                bucket: String,
                clientSecret: String,
                url: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.brand = brand
        self.bucket = bucket
        self.url = url
    }
    
    public init() {}
}

protocol GriffonProtocol {
    func getRefreshTokenFromKeyChain() -> String?
    func getIdTokenFromKeyChain() -> String?
    func cleanKeyChain() -> Bool
    func getUserProfiles() -> UserProfilesResponseModel?
}

public class Griffon {
    
    public static let shared = Griffon(config: GriffonConfigurations())
    
    public init(config: GriffonConfigurations) {
        self.config = config
    }
    public var config: GriffonConfigurations
    public var signUpModel: SignUpResponseModel? {
        didSet {
            guard let signModel = self.signUpModel else { return }
            self.setTokensToKeychain(signModel: signModel)
        }
    }
    public var signInModel: SignInResponseModel? {
        didSet {
            guard let signModel = self.signInModel else { return }
            self.setTokensToKeychain(signModel: signModel)
        }
    }
    public func setTokensToKeychain(signModel:TokenProtocol) {
        let keychain = KeychainSwift()
        keychain.set(signModel.idToken, forKey: KeychainKeys.idToken)
        keychain.set(signModel.refreshToken, forKey: KeychainKeys.refreshToken)
    }
    
    public var userInfo: ClientInfoResponseModel?
    var userProfiles: UserProfilesResponseModel?
    public var thirdpClients = [ThirdpClientResponseModel]()
    public var idToken: String? {
        return signInModel?.idToken ?? signUpModel?.idToken ?? nil
    }
    public var refreshToken: String? {
        return signInModel?.refreshToken ?? signUpModel?.refreshToken ?? nil
    }
    
    public var tokenType: String? {
        return signInModel?.tokenType ?? signUpModel?.tokenType ?? nil
    }
    
}

// MARK: - GriffonProtocol
extension Griffon: GriffonProtocol{
    
    public func cleanKeyChain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.clear()
    }
    
    public func getIdTokenFromKeyChain() -> String? {
        let keychain = KeychainSwift()
        guard let idToken = keychain.get(KeychainKeys.idToken) else {
            return nil
        }
        return idToken
    }
    
    public func getRefreshTokenFromKeyChain() -> String? {
        let keychain = KeychainSwift()
        guard let refreshToken = keychain.get(KeychainKeys.refreshToken) else {
            return nil
        }
        return refreshToken
    }
    
    public func getUserProfiles() -> UserProfilesResponseModel? {
        return self.userProfiles
    }
}

