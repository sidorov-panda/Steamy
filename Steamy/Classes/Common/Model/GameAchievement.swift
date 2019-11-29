//
//  Achievement.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class GameAchievement: Mappable {

  // MARK: -

 dynamic var name: String?
 dynamic var achieved: Bool = false
 dynamic var unlockTime: Int?

  // MARK: - Mappable

  required init?(map: Map) {

  }

  func mapping(map: Map) {
    name <- map["apiname"]
    achieved <- map["achieved"]
    unlockTime <- map["unlocktime"]
  }
}
