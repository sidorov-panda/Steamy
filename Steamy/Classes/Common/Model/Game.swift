//
//  Game.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class Game: Mappable {

  // MARK: -

  var id: Int?
  var name: String?
  var isFree: Bool = false
  var shortDesc: String?
  var detailedDesc: String?
  var aboutDesc: String?
  var headerImageURL: URL?
  var backgroundImageURL: URL?
  var screenshotURLs: [URL]?
  var price: String?
  var screenshots: [GameScreenshot]?

  // MARK: - Mappable

  required init?(map: Map) {
    
  }

  func mapping(map: Map) {
    id <- map["steam_appid"]
    name <- map["name"]
    isFree <- map["is_free"]
    shortDesc <- map["short_description"]
    detailedDesc <- map["detailed_description"]
    aboutDesc <- map["about_the_game"]
    headerImageURL <- (map["header_image"], URLTransform())
    backgroundImageURL <- (map["background"], URLTransform())
    price <- map["price_overview.final_formatted"]
    isFree <- map["is_free"]
    screenshots <- map["screenshots"]
  }
}
