//
//  GameStat.swift
//  Steamy
//
//  Created by Alexey Sidorov on 26.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class GameStat: Mappable {

  // MARK: -

  var displayName: String?
  var name: String?
  var value: Int?

  // MARK: - Mappable

  required convenience init?(map: Map) {
    self.init()
  }

  func mapping(map: Map) {
    displayName <- map["displayName"]
    name <- map["name"]
    value <- map["value"]
  }
}
