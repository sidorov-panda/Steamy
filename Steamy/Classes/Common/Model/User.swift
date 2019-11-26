//
//  User.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class User: Object, Mappable {

  // MARK: -

  dynamic var steamid: Int?
  dynamic var avatarURL: URL?
  dynamic var name: String?
  dynamic var nickname: String?
  dynamic var countryCode: String?
  dynamic var stateCode: String?
  dynamic var cityCode: Int?

  // MARK: - Mappable

  required convenience init?(map: Map) {
    self.init()
  }

  func mapping(map: Map) {
    steamid <- map["steamid"]
    avatarURL <- (map["avatarfull"], URLTransform())
    name <- map["realname"]
    nickname <- map["personaname"]
    countryCode <- map["loccountrycode"]
    stateCode <- map["locstatecode"]
    cityCode <- map["loccityid"]
  }
}
