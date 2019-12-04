//
//  ProfileRouter.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class ProfileRouter: BaseRouter {

  static var patterns: [String] = []

  static func viewController(path: [String], param: [String: Any]) -> UIViewController? {
    guard
      let idParam = param["id"] as? String,
      let userId = Int(idParam) else {
        return nil
    }
    return ProfileRouter.profileViewController(with: userId)
  }

  static func profileViewController(with userId: Int) -> UIViewController? {
    let steamAPI = UserManagerSteamAPIProvider()
    let userManager = UserManager(provider: steamAPI)
    steamAPI.cacheEnabled = true
    guard
      let userViewModel = ProfileViewModel(userId: userId,
                                           favoriteGameid: Session.shared.gameId,
                                           shouldShowFavoriteGame: Session.shared.userId == userId,
                                           dependencies: ProfileViewModelDependency(userManager: userManager, statisticCollector: AppManager())) else {
        return nil
    }
    let userVC = ProfileViewController()
    userVC.configure(with: userViewModel)
    return userVC
  }

}
