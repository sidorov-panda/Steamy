//
//  Session.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

class Session {

  static let shared = Session()

  private init() {}

  @UserDefault("userId", defaultValue: nil)
  var userId: Int?// = 76561198072598020
}
