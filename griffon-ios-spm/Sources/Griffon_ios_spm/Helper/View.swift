//
//  View.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 24.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public func setBackgroundColor(color: String) {
        guard let uIntBackgroundColor = color.convertToUInt() else {
            return
        }
        let backColor = UIColor(rgb: uIntBackgroundColor)
        self.backgroundColor = backColor
    }
    
    @discardableResult
    public func applyGradient(colours: [String], type: ButtonColorGradientType = .linear) -> CAGradientLayer {
        let uiColors = colours.compactMap { (stringColor) -> UIColor? in
            guard let uIntBackgroundColor = stringColor.convertToUInt() else {
                return nil
            }
            return UIColor(rgb: uIntBackgroundColor)
        }
        return self.applyGradient(colours: uiColors, locations: nil, type: type)
    }
    
    @discardableResult
    public func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    public func applyGradient(colours: [UIColor], locations: [NSNumber]?, type: ButtonColorGradientType = .linear) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.cornerRadius = 5
            
        if type == .radial {
            gradient.type = .radial
        }
        gradient.locations = [ 0, 0.3, 0.7, 1 ]
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
}
