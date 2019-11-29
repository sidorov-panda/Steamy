//
//  AppConfig.swift
//  Steamy
//
//  Created by Alexey Sidorov on 29.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

class AppConfig {

  private init() {}

  static let shared = AppConfig()

  var friendsUpdateTimeout = 60 * 60 * 24
  var statsUpdateTimeout = 0
  var steamAPIKey = "100170AD8C821B6B6948EA460DD9F89D"
}
