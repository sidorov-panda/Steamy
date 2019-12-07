//
//  ProfileRouter.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class ActivityRouter: BaseBuilder {

  static var patterns: [String] = []

  static func viewController(path: [String], param: [String : Any]) -> UIViewController? {
    return nil
  }

  static func activityViewController(with userId: Int) -> UIViewController? {

    let steamAPI = UserManagerSteamAPIProvider()
    let userManager = UserManager(provider: steamAPI)
    guard
      let userViewModel = ActivityViewModel(userId: userId,
                                            dependencies: ActivityViewModelDependency(userManager: userManager)) else {
        return nil
    }
    let userVC = ActivityViewController()
    userVC.configure(with: userViewModel)
    return userVC
  }

}
