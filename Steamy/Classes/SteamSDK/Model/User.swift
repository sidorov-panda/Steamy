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
  
  enum PersonaState: Int {
    case offline = 0
    case online
    case busy
    case away
    case snooze
    case lookingToTrade
    case lookingToPlay
  }
  
  enum VisibilityState: Int {
    case notVisible = 1
    case `public` = 3
  }

  // MARK: -

  var steamid: Int?
  var avatarURL: URL?
  var name: String?
  var nickname: String?
  var countryCode: String?
  var stateCode: String?
  var cityCode: Int?
  var personastate: PersonaState = .offline
  var visibilityState: VisibilityState = .notVisible
  var lastLogoff: Date?

  // MARK: - Mappable

  required convenience init?(map: Map) {
    self.init()
  }

  func mapping(map: Map) {
    steamid <- (map["steamid"], JSONStringToIntTransform())
    avatarURL <- (map["avatarfull"], URLTransform())
    name <- map["realname"]
    nickname <- map["personaname"]
    countryCode <- map["loccountrycode"]
    stateCode <- map["locstatecode"]
    cityCode <- map["loccityid"]
    personastate <- map["personastate"]
    visibilityState <- map["communityvisibilitystate"]
    lastLogoff <- (map["lastlogoff"], DateTransform())
  }

}
