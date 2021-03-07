//
//  ApiConfiguration.swift
//  OAuthSwift
//
//  Created by Farabi Bimbetov on 29.07.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit


public protocol ApiConfiguration {
    var clientId: String { get set }
    var clientSecret: String { get set }    
    var brand: String { get set }
    var bucket: String { get set }
    var url: String { get set }  
    var clientInfo: ClientInfoResponseModel? {get set}
}

public protocol SignControllersConfigurationProtocol {
    var brandTitle: String {get set}
    var mainColor: UIColor? {get set}
    var authTypes: [SignTypes] {get set}
}

public enum SignTypes{
    case mail
    case phone
}
