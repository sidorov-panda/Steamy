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

  var name: String?
  var displayName: String?
  var desc: String?
  var hidden: Bool = false
  var iconURL: URL?
  var icongrayURL: URL?
  var achieved: Bool = false
  var unlockTime: Int?

  // MARK: - Mappable

  required init?(map: Map) {

  }

  func mapping(map: Map) {
    name <- map["name"]
    displayName <- map["displayName"]
    hidden <- map["hidden"]
    desc <- map["desc"]
    iconURL <- (map["icon"], URLTransform())
    icongrayURL <- (map["icongray"], URLTransform())
    achieved <- map["achieved"]
    unlockTime <- map["unlocktime"]
  }
}
