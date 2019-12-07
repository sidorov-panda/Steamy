//
//  Article.swift
//  Steamy
//
//  Created by Alexey Sidorov on 06.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class Article: Mappable {

  // MARK: -

  var id: String?
  var title: String?
  var url: URL?
  var author: String?
  var contents: String?
  var feedlabel: String?
  var date: Date?

  // MARK: - Mappable

  required init?(map: Map) {
    
  }

  func mapping(map: Map) {
    id <- map["gid"]
    title <- map["title"]
    url <- (map["url"], URLTransform())
    author <- map["author"]
    contents <- map["contents"]
    feedlabel <- map["feedLabel"]
    date <- (map["date"], DateTransform())
  }

}
