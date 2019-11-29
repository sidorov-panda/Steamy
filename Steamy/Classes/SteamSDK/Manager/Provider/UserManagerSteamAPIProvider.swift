//
//  UserManagerSteamAPIProvider.swift
//  Steamy
//
//  Created by Alexey Sidorov on 29.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

/// This class shouldn't just pass the data to completion, but can transform errors into it's own error type
/// as well as transform data somehow
class UserManagerSteamAPIProvider: UserManagerProviderProtocol {

  //Using HTTP as a transport
  let steamAPI = SteamAPI(httpClient: HTTPClient())

  func userData(with id: Int, completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.user(id: id)) { (response, error) in

      var resp: JSONObject?
      var err: Error?

      defer {
        completion?(resp, err)
      }

      resp = response
      err = error
    }
  }

  func usersData(with ids: [Int], completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.users(ids: ids)) { (response, error) in

      var resp: JSONObject?
      var err: Error?

      defer {
        completion?(resp, err)
      }

      resp = response
      err = error
    }
  }

  func ownedGamesData(with userId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.ownedGames(userId: userId)) { (response, error) in
      completion?(response, error)
    }
  }

  func recentlyPlayedGamesData(with userId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.recentlyPlayedGames(userId: userId)) { (response, error) in
      completion?(response, error)
    }
  }

  func level(with userId: Int, completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.userLevel(id: userId)) { (response, error) in
      completion?(response, error)
    }
  }

  func achievementsData(with userId: Int, gameId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.achievements(userId: userId, gameId: gameId)) { (response, error) in
      completion?(response, error)
    }
  }

  func gameStatsData(with userId: Int, gameId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.gameStats(userId: userId, gameId: gameId)) { (response, error) in
      completion?(response, error)
    }
  }

  func friends(with userId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.friends(userId: userId)) { (response, error) in
      completion?(response, error)
    }
  }
}
