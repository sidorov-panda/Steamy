//
//  AppDelegate.swift
//  Steamy
//
//  Created by Alexey Sidorov on 21.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SteamLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    SteamLogin.steamApiKey = AppConfig.shared.steamAPIKey

    //!!!!!REMOVE BEFORE BUILD!!!!
    Session.shared.userId = 76561197960434622

    if let rootVC = UIApplication.shared.windows.first?.rootViewController as? RootViewController {
      let rootViewModel = RootViewModel()
      rootVC.configure(with: rootViewModel)
    }

    appearance()
    collectData()
		return true
	}

  func loadCountries() {
    
  }

  func appearance() {
    window?.tintColor = .white
    // Override point for customization after application launch.
    // Sets background to a blank/empty image
    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    // Sets shadow (line below the bar) to a blank image
    UINavigationBar.appearance().shadowImage = UIImage()
    // Sets the translucent background color
    UINavigationBar.appearance().backgroundColor = .defaultBackgroundCellColor
    UINavigationBar.appearance().barTintColor = .defaultBackgroundCellColor
    UINavigationBar.appearance().tintColor = .white
    // Set translucent. (Default value is already true, so this can be removed if desired.)
    UINavigationBar.appearance().isTranslucent = true
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]

    UITableViewHeaderFooterView.appearance().backgroundColor = UIColor.defaultBackgroundCellColor
    UIView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).backgroundColor = UIColor.defaultBackgroundCellColor
  }

  func collectData() {
    if let userId = Session.shared.userId {
      let gameId = Session.shared.gameId
      let collector = AppManager()
      collector.collectData(userId: userId, gameId: gameId)
    }
  }
}
