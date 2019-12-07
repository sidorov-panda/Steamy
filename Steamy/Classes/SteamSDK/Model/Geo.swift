//
//  Geo.swift
//  Steamy
//
//  Created by Alexey Sidorov on 05.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

class Geo {

  // MARK: -

  var countryName: String?
  var stateName: String?
  var cityName: String?

  init(countryCode: String, stateCode: String?, cityCode: String?) {
    let country = Geo.countries[countryCode] as? [String: Any]
    self.countryName = country?["name"] as? String

    if let stateCode = stateCode {
      if
        let states = country?["states"] as? [String: Any],
        let state = states[stateCode] as? [String: Any] {
          stateName = state["name"] as? String

        if
          let cityCode = cityCode,
          let cities = state["cities"] as? [String: Any],
          let city = cities[cityCode] as? [String: Any] {
          cityName = city["name"] as? String
        }
      }
    }
  }

  // MARK:  -

  static var countries: [String: Any] = {
    var filePath = Bundle.main.url(forResource: "steam_countries", withExtension: "json")
    var data = try! Data(contentsOf: filePath!)
    if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
      return json
    }
    return [:]
  }()
}
