//
//  ProfileRouter.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class GameListRouter: BaseBuilder {

  static var patterns: [String] = []

  static func viewController(path: [String], param: [String : Any]) -> UIViewController? {
    guard
      let idParam = param["id"] as? String,
      let userId = Int(idParam) else {
        return nil
    }
    return GameListRouter.gameListViewController(with: userId)
  }

  static func gameListViewController(with userId: Int) -> UIViewController? {
    let steamAPI = UserManagerSteamAPIProvider()
    let userManager = UserManager(provider: steamAPI)
    steamAPI.cacheEnabled = true
    guard
      let userViewModel = GameListViewModel(userId: userId,
                                           dependencies: GameListViewModelDependency(userManager: userManager)) else {
        return nil
    }
    let userVC = GameListViewController()
    userVC.configure(with: userViewModel)
    return userVC
  }
}
