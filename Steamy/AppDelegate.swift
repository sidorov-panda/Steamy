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

    SteamLogin.steamApiKey = "100170AD8C821B6B6948EA460DD9F89D"

    if let rootVC = UIApplication.shared.windows.first?.rootViewController as? RootViewController {
      let rootViewModel = RootViewModel()
      rootVC.configure(with: rootViewModel)
    }
		return true
	}
  
  func loadCountries() {
    
  }

}
