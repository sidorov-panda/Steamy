//
//  FriendDB.swift
//  Steamy
//
//  Created by Alexey Sidorov on 07.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RealmSwift

class FriendDB: Object {
  
  enum Fields: String {
    case steamidPk
    case userId
  }

  //Realm-use only
  @objc dynamic var steamidPk: String?
  @objc dynamic var userId: String?

  // MARK: -

  override class func primaryKey() -> String? {
    return "steamidPk"
  }
}
