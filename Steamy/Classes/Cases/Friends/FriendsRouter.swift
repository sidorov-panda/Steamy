//
//  ProfileRouter.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class FriendsRouter: BaseRouter {

  static var patterns: [String] {
    return ["friends"]
  }

  static func viewController(path: [String], param: [String : Any]) -> UIViewController? {
    guard
      let idParam = param["id"] as? String,
      let userId = Int(idParam) else {
        return nil
    }
    return FriendsRouter.friendsViewController(with: userId)
  }

  static func friendsViewController(with userId: Int) -> UIViewController? {
    var provider: UserManagerProviderProtocol
    if userId == Session.shared.userId {
      provider = UserManagerRealmProvider()
    } else {
      provider = UserManagerSteamAPIProvider()
    }

    let userManager = UserManager(provider: provider)
    guard
      let friendsViewModel = FriendsViewModel(userId: userId,
                                              dependencies: FriendsViewModelDependency(userManager: userManager)) else {
        return nil
    }
    let friendsVC = FriendsViewController()
    friendsVC.configure(with: friendsViewModel)
    return friendsVC
  }
}
