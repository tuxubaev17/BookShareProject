//
//  NetworkManager.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 03.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation
import Moya

public protocol Networkable {
    func verifyPinCode(sid: String, code: String, success: @escaping (VerifyPinCodeResponseModel) -> (), failure: @escaping (Error) -> ())
    func registerWithPhone(sid: String, password: String, success: @escaping (SignUpResponseModel) -> (), failure: @escaping (Error) -> ())
    func signUpWithMail(mail: String, password: String, success: @escaping (SignUpResponseModel)->(), failure: @escaping (Error)->())
    func sendPinCode(phone: String, success: @escaping (SignUpWithPhoneResponseModel)->(), failure: @escaping (Error)->())
    func getClientInfo(success: @escaping (ClientInfoResponseModel) -> (), failure: @escaping (Error) -> ())
    func signIn(username: String, password: String, success: @escaping (SignInResponseModel)->(), successMFA: @escaping (SignInMFAResponseModel)->(), failure: @escaping (Error)->())
    func refreshTokens(refreshToken: String, success: @escaping (SignInResponseModel) -> (), failure: @escaping (Error)->())
    func sendResetCode(username: String, resetType: String, success: @escaping (SendResetCodeResponseModel)->(), failure: @escaping (Error)->())
    func verifyResetPassword(sid: String, code: String, success: @escaping (VerifyResetPasswordResponseModel)->(), failure: @escaping(Error) -> ())
    func setNewPassword(sid: String, newPassword: String, success: @escaping (SetNewPasswordResponseModel) -> (), failure: @escaping (Error) -> ())
    func getUserProfiles(success: @escaping (UserProfilesResponseModel) -> (), failure: @escaping (Error) -> ())
    func get3rdpClients(success: @escaping ([ThirdpClientResponseModel]) -> (), failure: @escaping (Error) -> ())
    func authBy3rdpClient(sid: String, code: String, success: @escaping (SignInResponseModel) -> (), failure: @escaping (Error) -> ())
    func sendMFACode(sid: String, code: String, success: @escaping (SignInResponseModel) -> (), failure: @escaping (Error) -> ())
    func resendMFACode(sid: String, success: @escaping (SignInMFAResponseModel) -> (), failure: @escaping (Error) -> ())
}

public func parseResponse<T: Decodable>(result: Result<Moya.Response, MoyaError>, success: @escaping (T) -> (), failure: @escaping (Error) -> ()) {
    switch result {
    case let .success(response):
        do {
            let obj: T = try JSONDecoder().decode(T.self, from: response.data)
            success(obj)
        } catch let parseError {
            do {
                let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String:Any]
                if let message = json["message"] as? String,
                    let statusCode = json["status"] as? Int {
                    failure(NSError(domain: message, code: statusCode, userInfo: [:]))
                }
            } catch let error {
                failure(error)
            }
        }
    case let .failure(error):
        failure(error)
    }
}

public func parseSignInResponse<T: Decodable>(result: Result<Moya.Response, MoyaError>, success: @escaping (T) -> (), failure: @escaping (Error) -> (), successMFA: @escaping (SignInMFAResponseModel) -> ()?) {
    switch result {
    case let .success(response):
        do {
            let obj: T = try JSONDecoder().decode(T.self, from: response.data)
            success(obj)
        } catch _ {
            do {
                let signInMFA: SignInMFAResponseModel = try JSONDecoder().decode(SignInMFAResponseModel.self, from: response.data)
                successMFA(signInMFA)
            } catch _ {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String:Any]
                    if let message = json["message"] as? String,
                        let statusCode = json["status"] as? Int {
                        failure(NSError(domain: message, code: statusCode, userInfo: [:]))
                    }
                } catch let error {
                    failure(error)
                }
            }
        }
    case let .failure(error):
        failure(error)
    }
}

public class NetworkManager : Networkable {

    public var provider = MoyaProvider<OAuthService>()
    
    public init(config: GriffonConfigurations) {
        self.config = config
    }

    public static let instance = NetworkManager(config: GriffonConfigurations())
    public var config: GriffonConfigurations
    
    public func verifyPinCode(sid: String, code: String, success: @escaping (VerifyPinCodeResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.verifyPinCode(sid: sid, code: code)) { (result) in
             parseResponse(result: result, success: success, failure: failure)
         }
    }
    
    public func registerWithPhone(sid: String, password: String, success: @escaping (SignUpResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.registerWithPhone(sid: sid, password: password)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func signUpWithMail(mail: String, password: String, success: @escaping (SignUpResponseModel)->(), failure: @escaping (Error)->()) {
        provider.request(.signUpWithMail(clientId: self.config.clientId, clientSecret: self.config.clientSecret, userName: mail, password: password)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func sendPinCode(phone: String, success: @escaping (SignUpWithPhoneResponseModel)->(), failure: @escaping (Error)->()) {
        provider.request(.sendPinCode(clientId: self.config.clientId, clientSecret: self.config.clientSecret, phone: phone)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func getClientInfo(success: @escaping (ClientInfoResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.getClientInfo(clientId: self.config.clientId, clientSecret: self.config.clientSecret)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func signIn(username: String, password: String, success: @escaping (SignInResponseModel)->(), successMFA: @escaping (SignInMFAResponseModel)->(), failure: @escaping (Error)->()) {
        provider.request(.signIn(clientId: self.config.clientId, clientSecret: self.config.clientSecret, username: username, password: password)) { (result) in
            parseSignInResponse(result: result, success: success, failure: failure, successMFA: successMFA)
        }
    }
    
    public func refreshTokens(refreshToken: String, success: @escaping (SignInResponseModel) -> (), failure: @escaping (Error)->()) {
        provider.request(.refreshTokens(clientId: self.config.clientId, clientSecret: self.config.clientSecret, refreshToken: refreshToken)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func sendResetCode(username: String, resetType: String, success: @escaping (SendResetCodeResponseModel)->(), failure: @escaping (Error)->()) {
        provider.request(.sendResetCode(clientId: self.config.clientId, username: username, resetType: resetType)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func verifyResetPassword(sid: String, code: String, success: @escaping (VerifyResetPasswordResponseModel)->(), failure: @escaping(Error) -> ()) {
        provider.request(.resetPasswordVerify(sid: sid, code: code)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func setNewPassword(sid: String, newPassword: String, success: @escaping (SetNewPasswordResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.newPasswordSet(sid: sid, newPassword: newPassword)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func getUserProfiles(success: @escaping (UserProfilesResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.getUserProfile) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func get3rdpClients(success: @escaping ([ThirdpClientResponseModel]) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.get3rdpclients(bucket: self.config.bucket)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func authBy3rdpClient(sid: String, code: String, success: @escaping (SignInResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.authBy3rdpClient(sid: sid, code: code)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func sendMFACode(sid: String, code: String, success: @escaping (SignInResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.sendMFACode(sid: sid, code: code)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    public func resendMFACode(sid: String, success: @escaping (SignInMFAResponseModel) -> (), failure: @escaping (Error) -> ()) {
        provider.request(.resendMFACode(sid: sid)) { (result) in
            parseResponse(result: result, success: success, failure: failure)
        }
    }
    
    
}
