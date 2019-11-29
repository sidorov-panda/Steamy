//
//  UserManagerProviderProtocol.swift
//  Steamy
//
//  Created by Alexey Sidorov on 29.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

//Methods have postfix "data" because most of it returns raw dicts
protocol UserManagerProviderProtocol {
  typealias JSONObject = [String: Any]
  func userData(with userid: Int, completion: ((JSONObject?, Error?) -> ())?)
  func usersData(with ids: [Int], completion: ((JSONObject?, Error?) -> ())?)
  func ownedGamesData(with userId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func recentlyPlayedGamesData(with userId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func level(with userId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func achievementsData(with userId: Int, gameId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func gameStatsData(with userId: Int, gameId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func friends(with userId: Int, completion: ((JSONObject?, Error?) -> ())?)
}
