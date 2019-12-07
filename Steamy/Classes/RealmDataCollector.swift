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

protocol DataCollector {
  func collectData(userId: Int, gameId: Int)
}

class RealmDataCollector: DataCollector {

  private let keyDateFormatter = DateFormatter(withFormat: "yyyyMMdd", locale: "en_US")

  // MARK: -

  //Static keys, don't change!
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

  func addFakeData(userId: Int, gameId: Int, count: Int) {

    for day in 0..<count {
      let date = Date(timeIntervalSinceNow: TimeInterval(-60*60*24*day))
      [Stats.totalKills, Stats.totalDeaths].forEach { (stat) in
        let gameStat = GameStat()
        gameStat.name = stat.rawValue
        gameStat.displayName = stat.displayName()
        self.updateOrCreate(date: date,
                            userId: userId,
                            key: stat.rawValue,
                            value: String(Int.random(in: 0..<1000)),
                            displayName: stat.displayName())
      }
    }
  }

  func collectData(userId: Int, gameId: Int) {

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

  func updateOrCreate(date: Date = Date(), userId: Int, key: String, value: String, displayName: String?) {
    let date = keyDateFormatter.string(from: date)
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
