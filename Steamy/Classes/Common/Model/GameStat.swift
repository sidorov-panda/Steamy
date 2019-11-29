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

  var name: String?
  var value: Int?

  // MARK: - Mappable

  required convenience init?(map: Map) {
    self.init()
  }

  func mapping(map: Map) {
    name <- map["name"]
    value <- map["value"]
  }
}

class GameStatDB: Object {

  @objc dynamic var key: String?
  //why string? Realm seem to be ignoring from creating a field for Int for some reason
  @objc dynamic var user: String?
  @objc dynamic var name: String?
  @objc dynamic var value: String?
  @objc dynamic var date: String? //format 20190922

  override class func primaryKey() -> String? {
    return "key"
  }
}
