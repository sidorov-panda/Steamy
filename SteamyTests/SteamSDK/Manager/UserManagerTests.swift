//
//  UserManager.swift
//  SteamyTests
//
//  Created by Alexey Sidorov on 08.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import XCTest
@testable import Steamy

struct TestUserManagerProvider: UserManagerProviderProtocol {
  var cacheEnabled: Bool
  
  func userData(with userid: Int, completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    return 
  }
  
  func usersData(with ids: [Int], completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    
  }
  
  func ownedGamesData(with userId: Int, completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    <#code#>
  }
  
  func recentlyPlayedGamesData(with userId: Int, completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    <#code#>
  }
  
  func level(with userId: Int, completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    <#code#>
  }
  
  func achievementsData(with userId: Int, gameId: Int, completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    <#code#>
  }
  
  func gameStatsData(with userId: Int, gameId: Int, completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    <#code#>
  }
  
  func friends(with userId: Int, completion: ((TestUserManagerProvider.JSONObject?, Error?) -> ())?) {
    <#code#>
  }
  
  func badges(with userId: Int, completion: (([TestUserManagerProvider.JSONObject]?, Error?) -> ())?) {
    <#code#>
  }
}

class UserManagerTests: XCTestCase {

  override func setUp() {
    
  }

  override func tearDown() {
    
  }

  func testUser() {
    let userManager = UserManager(provider: TestUserManagerProvider(cacheEnabled: false))
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
        // Put the code you want to measure the time of here.
    }
  }
}
