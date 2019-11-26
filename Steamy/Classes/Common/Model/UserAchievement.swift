//
//  Achievement.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class UserAchievement: Mappable {

  // MARK: -

  var name: String?
  var achieved: Bool = false
  var unlockTime: Int?

  // MARK: - Mappable

  required init?(map: Map) {

  }

  func mapping(map: Map) {
    name <- map["apiname"]
    achieved <- map["achieved"]
    unlockTime <- map["unlocktime"]
  }
}
