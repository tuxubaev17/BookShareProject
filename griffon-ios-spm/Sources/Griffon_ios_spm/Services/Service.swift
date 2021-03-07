//
//  Service.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 30.07.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation
import Moya

public enum OAuthService {
    case signIn(clientId: String, clientSecret: String, username: String, password: String)
    case signUpWithMail(clientId: String, clientSecret: String, userName: String, password: String)
    case sendPinCode(clientId: String, clientSecret: String, phone: String)
    case verifyPinCode(sid: String, code: String)
    case registerWithPhone(sid: String, password: String)
    case getClientInfo(clientId: String, clientSecret: String)
    case refreshTokens(clientId: String, clientSecret: String, refreshToken: String)
    case sendResetCode(clientId: String, username: String, resetType: String)
    case resetPasswordVerify(sid: String, code: String)
    case newPasswordSet(sid: String, newPassword: String)
    case getUserProfile
    case get3rdpclients(bucket: String)
    case authBy3rdpClient(sid: String, code: String)
    case sendMFACode(sid: String, code: String)
    case resendMFACode(sid: String)
}

extension OAuthService: TargetType {
    
    public var baseURL: URL {
        let stringURL = Griffon.shared.config.url
        guard let url = URL(string: stringURL) else {
            fatalError()
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .signIn:
            return "/oauth/token"
        case .signUpWithMail(_, _, _, _):
            return "/oauth/signup"
        case .sendPinCode(_, _, _):
            return "/oauth/signup"
        case .verifyPinCode(_, _):
            return "/oauth/signup/phone/verify"
        case .registerWithPhone(_, _):
            return "/oauth/register"
        case .getClientInfo(_, _):
            return "/mgmt/helpers/app-info"
        case .refreshTokens(_, _, _):
            return "/oauth/token"
        case .sendResetCode(_, _, _):
            return "/oauth/password/reset"
        case .resetPasswordVerify(_, _):
            return "/oauth/password/reset/verify"
        case .newPasswordSet(_, _):
            return "/oauth/password/reset"
        case .getUserProfile:
            return "/oauth/profile"
        case .get3rdpclients(_):
            return "/mgmt/helpers/social-login/providers"
        case .authBy3rdpClient(_, _):
            return "/oauth/openid/token"
        case .sendMFACode(_, _):
            return "/oauth/token/mfa"
        case .resendMFACode(_):
            return "/oauth/mfa/send_code"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getClientInfo, .getUserProfile, .get3rdpclients, .authBy3rdpClient:
            return .get
        case .signIn, .signUpWithMail, .sendPinCode, .verifyPinCode,
             .registerWithPhone, .refreshTokens, .sendResetCode, .resetPasswordVerify,
             .sendMFACode, .resendMFACode:
            return .post
        case .newPasswordSet:
            return .put
        }
    }
    
    public var task: Task {
        switch self {
        case let .signUpWithMail(clientId, clientSecret, userName, password):
            let par = ["client_id": clientId,
                       "client_secret" : clientSecret,
                       "username" : userName,
                       "password" : password]
            return .requestParameters(parameters: par, encoding: JSONEncoding.default)
        case let .signIn(clientId, clientSecret, userName, password):
            let params = ["client_id": clientId,
                          "client_secret" : clientSecret,
                          "username" : userName,
                          "password" : password,
                          "grant_type" : "password"]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .sendPinCode(clientId, clientSecret, phone):
            let parameters = ["client_id": clientId,
                              "client_secret" : clientSecret,
                              "username" : phone]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case let .verifyPinCode(sid, code):
            let parameters = ["sid" : sid]
            let body = ["code" : code]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                return .requestCompositeData(bodyData: jsonData, urlParameters: parameters)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        case let .registerWithPhone(sid, password):
            let parameters = ["sid" : sid]
            let body = ["password" : password]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                return .requestCompositeData(bodyData: jsonData, urlParameters: parameters)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        case let .getClientInfo(clientId, clientSecret):
            let parameters = ["client_id" : clientId,
                              "client_secret" : clientSecret]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .refreshTokens(clientId, clientSecret, refreshToken):
            let params = ["client_id": clientId,
                          "client_secret" : clientSecret,
                          "grant_type": "refresh_token",
                          "refresh_token": refreshToken]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .sendResetCode(clientId, username, resetType):
            let body = ["client_id": clientId,
                        "username": username,
                        "reset_option": resetType]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                return .requestCompositeData(bodyData: jsonData, urlParameters: [:])
            } catch let error {
                fatalError(error.localizedDescription)
            }
        case let .resetPasswordVerify(sid, code):
            let params = ["sid"  : sid,
                          "code" : code]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .newPasswordSet(sid, newPassword):
            let params = ["sid" : sid]
            let body = [ "new_password" : newPassword]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                return .requestCompositeData(bodyData: jsonData, urlParameters: params)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        case .getUserProfile:
            return .requestPlain
        case let .get3rdpclients(bucket):
            let params = ["bucket" : bucket]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .authBy3rdpClient(sid, code):
            let params = ["sid"  : sid,
                          "code" : code]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .sendMFACode(sid, code):
            let params = ["sid" : sid]
            let body = [ "code" : code]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                return .requestCompositeData(bodyData: jsonData, urlParameters: params)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        case let .resendMFACode(sid):
            let params = ["sid" : sid]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    public var sampleData: Data {
        return Data()
        switch self {
        case .signUpWithMail(let clientId, let clientSecret, let userName, let password):
            return "{'client_id': \(clientId), 'client_secret': \(clientSecret), 'userName': \(userName), 'password': \(password)}".utf8Encoded
        case .signIn:
            return "".utf8Encoded
        case .sendPinCode(_, _, _):
            return "".utf8Encoded
        case .verifyPinCode(_, _):
            return "".utf8Encoded
        case .registerWithPhone(_, _):
            return "".utf8Encoded
        case .getClientInfo(_, _):
            return "".utf8Encoded
        case .refreshTokens(_, _, _):
            return "".utf8Encoded
        case .sendResetCode(_, _, _):
            return "".utf8Encoded
        case .resetPasswordVerify(_, _):
            return "".utf8Encoded
        case .newPasswordSet(_, _):
            return "".utf8Encoded
        case .getUserProfile:
            return "".utf8Encoded
        case .get3rdpclients(_):
            return "".utf8Encoded
        case .authBy3rdpClient(_, _):
            return "".utf8Encoded
        case .sendMFACode(_, _):
            return "".utf8Encoded
        case .resendMFACode(_):
            return "".utf8Encoded
        }
    }
    
    public var headers: [String: String]? {
        var httpHeaders: [String: String] = [:]
        if ((self.path == "/oauth/password/reset") || (self.path == "/oauth/profile")), let idToken = Griffon.shared.idToken, let type = Griffon.shared.tokenType {
            httpHeaders["Authorization"] = type + " " + idToken
        }
        httpHeaders["Content-type"] = "application/json"
        httpHeaders["accept-language"] = LocaleLanguage().current()        
        return httpHeaders
    }
    
}
