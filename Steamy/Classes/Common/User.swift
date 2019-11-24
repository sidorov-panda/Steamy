//
//  User.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {

  // MARK: -

  var steamid: Int?
  var avatarURL: URL?
  var name: String?
  var nickname: String?
  var countryCode: String?
  var stateCode: String?
  var cityCode: Int?

  // MARK: - Mappable

  required init?(map: Map) {
    
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
