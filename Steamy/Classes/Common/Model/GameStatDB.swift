//
//  GameStatDB.swift
//  Steamy
//
//  Created by Alexey Sidorov on 07.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RealmSwift

///Using different model, so we will gave a better flexibility in storing additional fields
class GameStatDB: Object {

  @objc dynamic var key: String?
  //why string? Realm seem to be ignoring from creating a field for Int for some reason
  @objc dynamic var user: String?
  @objc dynamic var displayName: String?
  @objc dynamic var name: String?
  @objc dynamic var value: String?
  @objc dynamic var date: String? //format 20190922

  override class func primaryKey() -> String? {
    return "key"
  }
}
