//
//  Localize.swift
//  OAuthSwiftDemo
//
//  Created by Farabi Bimbetov on 12.08.2020.
//  Copyright © 2020 Dongri Jin. All rights reserved.
//

import Foundation


struct LocaleLanguage {
    func current() -> String {
        return (Locale.preferredLanguages.first ?? "en")[0..<2]
    }
}
