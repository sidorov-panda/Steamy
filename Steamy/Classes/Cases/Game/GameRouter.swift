//
//  GameRouter.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import UIKit

class GameRouter: BaseRouter {

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
    return GameRouter.gameViewController(with: userId, gameId: gameId)
  }

  static func gameViewController(with userId: Int, gameId: Int) -> UIViewController? {
    let userSteamAPI = UserManagerSteamAPIProvider()
    let gameSteamAPI = GameManagerSteamAPIProvider()
    let userManager = UserManager(provider: userSteamAPI)
    let gameManager = GameManager(provider: gameSteamAPI)
    guard
      let userViewModel = GameViewModel(
        userId: userId,
        gameId: gameId,
        dependencies: GameViewModelDependency(userManager: userManager,
                                              gameManager: gameManager)) else {
        return nil
    }
    let userVC = GameViewController()
    userVC.configure(with: userViewModel)
    return userVC
  }
}
