//
//  KeyboardManagerDelegate.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 08.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import UIKit

protocol KeyboardManagerDelegate: class {
    func keyboardVisibilityChanged(with height: CGFloat)
}
