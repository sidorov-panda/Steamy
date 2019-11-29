//
//  UserStatDataCollector.swift
//  Steamy
//
//  Created by Alexey Sidorov on 26.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class AppManager {

  enum TimeoutKeys: String {
    case gameStats
    case friends
  }

  enum Stats: String, CaseIterable {
    case totalKills = "total_kills"
    case totalDeaths = "total_deaths"
  }

  let realm = try! Realm()

  func collectData() {
    guard let userId = Session.shared.userId else {
      return
    }
    let gameId = Session.shared.gameId

    let steamAPIProvider = UserManagerSteamAPIProvider()
    let userManager = UserManager(provider: steamAPIProvider)

    userManager.gameStats(userId: userId, gameId: gameId, completion: { stats, achiev, error in
      //stats to save:
      let filteredStats = stats?.filter { return Stats.allCases.map { $0.rawValue }.contains($0.name) } ?? []
      filteredStats.forEach { (stat) in
        guard
          let key = stat.name,
          let value = stat.value else {
            return
        }
        self.updateOrCreate(userId: userId, key: key, value: String(value))
      }
    })

    userManager.friends(userId: userId) { (users, error) in

      (users ?? []).forEach({ (user) in
        try! self.realm.write {
          self.realm.create(FriendDB.self, value: [
            "steamidPk": String(user.steamid ?? 0),
            "userId": String(userId)
          ], update: .all)

          self.realm.create(UserDB.self, value: ["steamidPk": String(user.steamid ?? 0),
                                                 "name": user.name,
                                                 "avatarURL": user.avatarURL?.absoluteString,
                                                 "nickname": user.nickname,
                                                 "countryCode": user.countryCode,
                                                 "stateCode": user.stateCode,
                                                 "cityCode": Int(user.cityCode ?? 0)
          ], update: .all)
        }
      })
    }
  }

  let keyDateDormatter = DateFormatter(withFormat: "yyyyMMdd", locale: "en_US")

  func updateOrCreate(userId: Int, key: String, value: String) {
    let date = keyDateDormatter.string(from: Date())
    let todayKey = "\(date)_\(key)"
    try! realm.write {
      self.realm.create(GameStatDB.self, value: ["user": String(userId), "name": key, "value": value, "date": date, "key": todayKey], update: .all)
    }
  }
}
