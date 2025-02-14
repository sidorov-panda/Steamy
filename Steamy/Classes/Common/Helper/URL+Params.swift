//
//  URL+Params.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

extension URL {

  func params() -> [String : Any] {
    var res = [String : Any]()
    if let urlComponents = URLComponents(string: self.absoluteString),
      let queryItems = urlComponents.queryItems {
      queryItems.forEach({ (item) in
        res[item.name] = item.value
      })
    }
    return res
  }

  func paramForKey(_ key: String) -> String? {
    if let components = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems?.filter({ (item) -> Bool in
      return item.name == key
    }) {
      if components.count > 0 {
        return components.first?.value ?? nil
      }
    }
    return nil
  }
}
