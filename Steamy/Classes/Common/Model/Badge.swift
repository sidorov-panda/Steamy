//
//  Badge.swift
//  Steamy
//
//  Created by Alexey Sidorov on 03.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

class Badge: Mappable {

  var id: Int?

  required init?(map: Map) {
    
  }

  func mapping(map: Map) {
    id <- map["id"]
  }
}
