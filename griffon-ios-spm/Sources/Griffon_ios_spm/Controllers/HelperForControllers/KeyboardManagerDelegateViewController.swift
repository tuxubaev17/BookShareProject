//
//  KeyboardManagerDelegateViewController.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 08.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation

protocol KeyboardManagerDelegateViewController: class {
    var keyboardDelegate: KeyboardManagerDelegate? { get set }
}
