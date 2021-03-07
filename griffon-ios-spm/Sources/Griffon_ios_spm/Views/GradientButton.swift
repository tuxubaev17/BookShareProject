//
//  GradientButton.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 24.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

class GradientButton: UIButton {
    
    var colorSettings: ButtonColor?
    
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    convenience init(frame: CGRect, colorSettings: ButtonColor, gradientSet: [[CGColor]]) {
        self.init(frame: frame)
        self.colorSettings = colorSettings
        self.gradientSet = gradientSet
        self.setSignInButtonColor(buttonColor: colorSettings)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSignInButtonColor(buttonColor: ButtonColor) {
        switch buttonColor.type {
        case .gradient:
            self.applyGradient(colours: buttonColor.colors, type: buttonColor.gradientType)
        case .static_type:
            guard let firstColor = buttonColor.colors.first else { return }
            self.setBackgroundColor(color: firstColor)
        }
    }
    
    private func buttonWithAnimation(buttonColor: ButtonColor) {
        let uiColors = buttonColor.colors.compactMap { (stringColor) -> CGColor? in
            return stringColor.convertToUIImage()?.cgColor
        }
        for i in 0...(uiColors.count - 1) {
            gradientSet.append([uiColors[i], uiColors[(i + 1) % (uiColors.count)]])
        }
        if buttonColor.gradientType == .radial {
            gradient.type = .radial
        }
        gradient.frame = self.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.cornerRadius = 5
        gradient.drawsAsynchronously = true
        self.layer.insertSublayer(gradient, at: 0)
        
        self.animateGradient()
    }
    
    private func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 3.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.repeatCount = Float.infinity
        gradientChangeAnimation.autoreverses = true
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
    }

}
