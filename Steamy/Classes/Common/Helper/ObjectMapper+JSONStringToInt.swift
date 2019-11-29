//
//  ObjectMapper+JSONStringToInt.swift
//  Steamy
//
//  Created by Alexey Sidorov on 27.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class JSONStringToIntTransform: TransformType {

  typealias Object = Int
  typealias JSON = String

  init() {}

  func transformFromJSON(_ value: Any?) -> Int? {
    if let strValue = value as? String {
      return Int(strValue)
    }
    return value as? Int ?? nil
  }

  func transformToJSON(_ value: Int?) -> String? {
    if let intValue = value {
      return "\(intValue)"
    }
    return nil
  }
}
