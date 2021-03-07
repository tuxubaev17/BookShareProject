//
//  String.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 12.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    public func convertToUInt() -> UInt? {
        return UInt(String(self.dropFirst()), radix: 16)
    }
    
    // For hex string with format #FFFFFF
    public func convertToUIImage() -> UIColor? {
        guard let uIntBackgroundColor = self.convertToUInt() else {
            return nil
        }
        return UIColor(rgb: uIntBackgroundColor)
    }
    
    public func checkLoginType() -> LoginType {
        if self.isPhoneNumber() {
            return .phone_number
        } else if self.isMail() {
            return .email
        } else {
            return .wrongFormat
        }
    }
}


extension String {
    
    public func isPhoneNumber() -> Bool {
        let PHONE_REGEX = "^((\\+7)|(8))[0-9]{10,11}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    public func convertPhoneType() -> String {
        var value = self
        if value.first == "8" {
            value = "+7" + value.dropFirst()
        }
        return value
    }
    
    public func isMail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

extension String {
    public var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    public var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
