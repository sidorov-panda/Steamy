//
//  UserGame.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class UserGame: Mappable {

  // MARK: -

  var id: Int?
  var name: String?
  var logoURL: URL?
  var iconURL: URL?
  var playtime: Int?

  // MARK: - Mappable

  required init?(map: Map) {
    
  }

  func mapping(map: Map) {
    id <- map["appid"]
    name <- map["name"]
    playtime <- map["playtime_forever"]
    //TODO: move to transformer
    if
      let appId = id,
      let iconHash = map.JSON["img_icon_url"] as? String,
      let logoHash = map.JSON["img_logo_url"] as? String {
        iconURL = URL(string: "http://media.steampowered.com/steamcommunity/public/images/apps/\(appId)/\(iconHash).jpg")
        logoURL = URL(string: "http://media.steampowered.com/steamcommunity/public/images/apps/\(appId)/\(logoHash).jpg")
    }
  }
}
