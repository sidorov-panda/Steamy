//
//  GameScreenshot.swift
//  Steamy
//
//  Created by Alexey Sidorov on 05.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class GameScreenshot: Mappable {
  
  // MARK: -

  var id: Int?
  var thumbnailURL: URL?
  var fullURL: URL?
  
  // MARK: - Mappable

  required init?(map: Map) {
    
  }

  func mapping(map: Map) {
    id <- map["id"]
    thumbnailURL <- (map["thumbnail_path"], URLTransform())
    fullURL <- (map["path_full"], URLTransform())
  }
}
