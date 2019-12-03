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

class User: Mappable {

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
    steamid <- (map["steamid"], JSONStringToIntTransform())
    avatarURL <- (map["avatarfull"], URLTransform())
    name <- map["realname"]
    nickname <- map["personaname"]
    countryCode <- map["loccountrycode"]
    stateCode <- map["locstatecode"]
    cityCode <- map["loccityid"]
  }

  // MARK: -
}

///Using different model, so we will gave a better flexibility in storing additional fields
class UserDB: Object {

  //Realm-use only
  @objc dynamic var steamidPk: String?

  // MARK: -

  @objc dynamic var name: String?
  @objc dynamic var avatarURL: String?
  @objc dynamic var nickname: String?
  @objc dynamic var countryCode: String?
  @objc dynamic var stateCode: String?
  dynamic var cityCode = RealmOptional<Int>()

  // MARK: -

  override class func primaryKey() -> String? {
    return "steamidPk"
  }
}

class FriendDB: Object {

  //Realm-use only
  @objc dynamic var steamidPk: String?
  @objc dynamic var userId: String?

  // MARK: -

  override class func primaryKey() -> String? {
    return "steamidPk"
  }
}
