//
//  Int.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 27.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

extension Int {
    public func coolDownType() -> String {
        var firstPart = ""
        var secondPart = ""
        let minutes = (self/60)
        if minutes/10 >= 1 {
            firstPart = String(minutes)
        } else {
            firstPart = "0\(minutes)"
        }
        let seconds = self%60
        if seconds/10 >= 1 {
            secondPart = String(seconds)
        } else {
            secondPart = "0\(seconds)"
        }
        return firstPart + " : " + secondPart
    }
}
