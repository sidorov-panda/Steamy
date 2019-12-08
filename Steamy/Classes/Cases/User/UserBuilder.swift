//
//  UserRouter.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class UserBuilder: BaseBuilder {

  static var patterns: [String] {
    return ["user"]
  }

  static func viewController(path: [String], param: [String : Any]) -> UIViewController? {
    guard
      let idParam = param["id"] as? String,
      let userId = Int(idParam) else {
        return nil
    }
    return UserBuilder.userViewController(with: userId)
  }

  static func userViewController(with userId: Int) -> UIViewController? {

    let steamAPI = UserManagerSteamAPIProvider()
    let userManager = UserManager(provider: steamAPI)
    guard
      let userViewModel = UserViewModel(userId: userId,
                                        dependencies: UserViewModelDependency(userManager: userManager)) else {
        return nil
    }
    let userVC = UserViewController()
    userVC.configure(with: userViewModel)
    return userVC
  }

  static func userViewController(with user: User) -> UIViewController? {

    let steamAPI = UserManagerSteamAPIProvider()
    let userManager = UserManager(provider: steamAPI)
    guard
      let userViewModel = UserViewModel(user: user,
                                        dependencies: UserViewModelDependency(userManager: userManager)) else {
        return nil
    }
    let userVC = UserViewController()
    userVC.configure(with: userViewModel)
    return userVC
  }

}
