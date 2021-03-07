//
//  ButtonColor.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 21.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

public struct ButtonColor {
    var type: ButtonColorType
    var gradientType: ButtonColorGradientType
    var colors: [String]
}

extension ButtonColor: Decodable {
    
    private enum ButtonColorCodingKeys: String, CodingKey {
        case type
        case gradientType = "gradient_type"
        case colors = "color"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ButtonColorCodingKeys.self)
        type = try container.decode(ButtonColorType.self, forKey: .type)
        gradientType = try container.decode(ButtonColorGradientType.self, forKey: .gradientType)
        colors = try container.decode([String].self, forKey: .colors)        
    }
}

public enum ButtonColorGradientType: String, Decodable {
    case radial
    case linear
}

public enum ButtonColorType: String, Decodable {
    case gradient
    case static_type = "static"
}
