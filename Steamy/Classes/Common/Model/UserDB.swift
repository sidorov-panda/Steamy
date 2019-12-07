//
//  UserDB.swift
//  Steamy
//
//  Created by Alexey Sidorov on 07.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RealmSwift

///Using different model, so we will gave a better flexibility in storing additional fields
class UserDB: Object {
  
  enum Fields: String {
    case steamidPk
    case name
    case avatarURL
    case nickname
    case countryCode
    case stateCode
    case cityCode
  }

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
