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

  // MARK: -

  enum TimeoutKeys: String {
    case gameStats
    case friends
    case favoriteGame
  }

  // MARK: -

  enum Stats: String, CaseIterable {
    case totalKills = "total_kills"
    case totalDeaths = "total_deaths"

    func displayName() -> String {
      switch self {
      case .totalDeaths:
        return "Deaths"

      case .totalKills:
        return "Kills"
      }
    }
  }

  let realm = try! Realm()

  func collectData() {
    guard let userId = Session.shared.userId else {
      return
    }
    let gameId = Session.shared.gameId

    let steamAPIProvider = UserManagerSteamAPIProvider()
    steamAPIProvider.cacheEnabled = false
    let userManager = UserManager(provider: steamAPIProvider)

    userManager.gameStats(userId: userId,
                          gameId: gameId,
                          completion: { stats, achiev, error in
      //stats to save:
      let filteredStats = stats?.filter { return Stats.allCases.map { $0.rawValue }.contains($0.name) } ?? []
      filteredStats.forEach { (stat) in
        guard
          let key = stat.name,
          let value = stat.value else {
            return
        }
        self.updateOrCreate(userId: userId, key: key, value: String(value), displayName: stat.displayName ?? Stats(rawValue: key)?.displayName() )
      }
    })

    userManager.friends(userId: userId) { (users, error) in

      (users ?? []).forEach({ (user) in
        try! self.realm.write {
          self.realm.create(FriendDB.self, value: [
            FriendDB.Fields.steamidPk.rawValue: String(user.steamid ?? 0),
            FriendDB.Fields.userId.rawValue: String(userId)
          ], update: .all)

          self.realm.create(UserDB.self, value: [UserDB.Fields.steamidPk.rawValue: String(user.steamid ?? 0),
                                                 UserDB.Fields.name.rawValue: user.name,
                                                 UserDB.Fields.avatarURL.rawValue: user.avatarURL?.absoluteString,
                                                 UserDB.Fields.nickname.rawValue: user.nickname,
                                                 UserDB.Fields.countryCode.rawValue: user.countryCode,
                                                 UserDB.Fields.stateCode.rawValue: user.stateCode,
                                                 UserDB.Fields.cityCode.rawValue: Int(user.cityCode ?? 0)
          ], update: .all)
        }
      })
    }
  }

  let keyDateFormatter = DateFormatter(withFormat: "yyyyMMdd", locale: "en_US")

  func updateOrCreate(userId: Int, key: String, value: String, displayName: String?) {
    let date = keyDateFormatter.string(from: Date())
    let todayKey = "\(date)_\(key)"
    try! realm.write {
      self.realm.create(GameStatDB.self, value: ["user": String(userId),
                                                 "displayName": displayName,
                                                 "name": key,
                                                 "value": value,
                                                 "date": date,
                                                 "key": todayKey],
                        update: .all)
    }
  }
}
