//
//  FavoriteGameStatisticsProvider.swift
//  Steamy
//
//  Created by Alexey Sidorov on 01.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RealmSwift

class RealmStatisticProvider: StatisticsProvider {

  let realm = try! Realm()

  // MARK:  - FavoriteGameStatisticsProvider

  let dateFormatter = DateFormatter(withFormat: "yyyyMMdd", locale: "en_US")

  func statistics(for userId: Int) -> [Date: [String: (String?, Int)]] {
    let objects = realm.objects(GameStatDB.self).filter("user==%@", String(userId))
    var ret: [Date: [String: (String?, Int)]] = [:]

    objects.forEach { (game) in
      guard
        let dateString = game.date,
        let date = dateFormatter.date(from: dateString),
        let key = game.name,
        let val = Int(game.value ?? "")
      else {
          return
      }
      if nil == ret[date] {
        ret[date] = [:]
      }
      ret[date]?[key] = (game.displayName, val)
    }
    return ret
  }
}
