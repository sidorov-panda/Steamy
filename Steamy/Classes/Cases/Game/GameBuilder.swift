//
//  GameRouter.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import UIKit

class GameBuilder: BaseBuilder {

  static var patterns: [String] {
    return ["user"]
  }

  static func viewController(path: [String], param: [String: Any]) -> UIViewController? {
    guard
      let userIdParam = param["userIn"] as? String,
      let idParam = param["id"] as? String,
      let userId = Int(userIdParam),
      let gameId = Int(idParam) else {
        return nil
    }
    return GameBuilder.gameViewController(with: userId, gameId: gameId, timePlayed: nil)
  }

  static func gameViewController(with userId: Int, gameId: Int, timePlayed: Int? = nil) -> UIViewController? {
    let userSteamAPI = UserManagerSteamAPIProvider()
    let gameSteamAPI = GameManagerSteamAPIProvider()
    let userManager = UserManager(provider: userSteamAPI)
    userSteamAPI.cacheEnabled = true
    let gameManager = GameManager(provider: gameSteamAPI)
    gameSteamAPI.cacheEnabled = true
    guard
      let userViewModel = GameViewModel(
        userId: userId,
        gameId: gameId,
        timePlayed: timePlayed,
        isFavoriteGame: gameId == Session.shared.gameId,
        dependencies: GameViewModelDependency(userManager: userManager,
                                              gameManager: gameManager,
                                              statisticProvider: RealmStatisticProvider())) else {
        return nil
    }
    let userVC = GameViewController()
    userVC.configure(with: userViewModel)
    return userVC
  }
}
