//
//  URL.swift
//  griffon-sdk
//
//  Created by Farabi Bimbetov on 14.09.2020.
//  Copyright © 2020 Dar. All rights reserved.
//

import Foundation


extension URL {
  func params() -> [String:Any] {
    var dict = [String:Any]()

    if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
      if let queryItems = components.queryItems {
        for item in queryItems {
          dict[item.name] = item.value!
        }
      }
      return dict
    } else {
      return [:]
    }
  }
}
