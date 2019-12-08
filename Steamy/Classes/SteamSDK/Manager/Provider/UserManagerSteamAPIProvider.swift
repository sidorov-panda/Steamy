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

  //Provider Error cases
  enum UserManagerSteamAPIProviderError: Error {
    case wrongResponse
  }

  //Using HTTP as a transport
  let steamAPI = SteamAPI(httpClient: HTTPClient())

  var cacheEnabled: Bool = false

  func userData(with id: Int, completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.user(id: id), refresh: !cacheEnabled) { (response, error) in

      var resp: JSONObject?
      var err: Error?

      defer {
        completion?(resp, err)
      }

      guard error == nil else {
        err = error
        return
      }

      if
        let response = response?["response"] as? [String: Any],
        let users = response["players"] as? [[String: Any]],
        let firstUser = users.first {
          resp = firstUser
      } else {
        err = UserManagerSteamAPIProviderError.wrongResponse
      }
    }
  }

  func usersData(with ids: [Int], completion: (([JSONObject]?, Error?) -> ())?) {
    steamAPI.request(.users(ids: ids), refresh: !cacheEnabled) { (response, error) in

      var resp: [JSONObject]?
      var err: Error?

      defer {
        completion?(resp, err)
      }

      guard error == nil else {
        err = error
        return
      }

      if
        let response = response?["response"] as? [String: Any],
        let usersArray = response["players"] as? [[String: Any]] {
        resp = usersArray
      } else {
        err = UserManagerSteamAPIProviderError.wrongResponse
      }
    }
  }

  func ownedGamesData(with userId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.ownedGames(userId: userId), refresh: !cacheEnabled) { (response, error) in
      completion?(response, error)
    }
  }

  func recentlyPlayedGamesData(with userId: Int, completion: (([UserManagerSteamAPIProvider.JSONObject]?, Error?) -> ())?) {
    steamAPI.request(.recentlyPlayedGames(userId: userId), refresh: !cacheEnabled) { (response, error) in
      var games: [JSONObject]?
      var err: Error?
      defer {
        completion?(games, err)
      }
      
      guard error == nil else {
        err = error
        return
      }
      
      if
        let response = response?["response"] as? [String: Any],
        let gamesArray = response["games"] as? [[String: Any]] {
        games = gamesArray
      } else {
        err = UserManagerSteamAPIProviderError.wrongResponse
      }
    }
  }

  func level(with userId: Int, completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.userLevel(id: userId), refresh: !cacheEnabled) { (response, error) in
      completion?(response, error)
    }
  }

  func achievementsData(with userId: Int, gameId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.achievements(userId: userId, gameId: gameId), refresh: !cacheEnabled) { (response, error) in
      completion?(response, error)
    }
  }

  func gameStatsData(with userId: Int, gameId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.gameStats(userId: userId, gameId: gameId), refresh: !cacheEnabled) { (response, error) in
      completion?(response, error)
    }
  }

  func friends(with userId: Int, completion: ((UserManagerSteamAPIProvider.JSONObject?, Error?) -> ())?) {
    steamAPI.request(.friends(userId: userId), refresh: !cacheEnabled) { (response, error) in
      completion?(response, error)
    }
  }

  func badges(with userId: Int, completion: (([UserManagerSteamAPIProvider.JSONObject]?, Error?) -> ())?) {
    steamAPI.request(.badges(userId: userId), refresh: !cacheEnabled) { (response, error) in
      var preparedResponse = [[String: Any]]()
      var err: Error?
      defer {
        completion?(preparedResponse, err)
      }

      guard error == nil else {
        err = error
        return
      }

      guard
        let response = response?["response"] as? [String: Any],
        let badges = response["badges"] as? [[String: Any]] else {
          err = UserManagerSteamAPIProviderError.wrongResponse
          return
      }
      preparedResponse = badges
    }
  }
}
