//
//  UserManager.swift
//  Steamy
//
//  Created by Alexey Sidorov on 22.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

protocol UserManagerProviderProtocol {
  typealias JSONObject = [String: Any]
  func userData(with userid: Int, completion: ((JSONObject?, Error?) -> ())?)
  func ownedGamesData(with userId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func recentlyPlayedGamesData(with userId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func level(with userId: Int, completion: ((JSONObject?, Error?) -> ())?)
  func achievementsData(with userId: Int, gameId: Int, completion: ((JSONObject?, Error?) -> ())?)
}

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
}

class UserManager {

  enum UserManagerError: Error {
    case noUser
    case wrongResponse
  }

  // MARK: -

  private var provider: UserManagerProviderProtocol

  init(provider: UserManagerProviderProtocol) {
    self.provider = provider
  }

  // MARK: - Methods

  func user(id: Int, completion: ((User?, Error?) -> ())?) {
    //Transforming into User Model
    self.provider.userData(with: id) { (response, error) in
      var user: User?
      var err: Error?

      defer {
        completion?(user, err)
      }

      guard error == nil else {
        err = error
        return
      }

      if
        let response = response?["response"] as? [String: Any],
        let users = response["players"] as? [[String: Any]],
        let firstUser = users.first,
        let mappedUser = Mapper<User>().map(JSON: firstUser) {
          user = mappedUser
      } else {
        err = UserManagerError.noUser
      }
    }
  }

  func games(userId: Int, completion: (([UserGame]?, Error?) -> ())?) {
    //Transforming into User Model
    self.provider.ownedGamesData(with: userId) { (response, error) in
      var games: [UserGame]?
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
          games = Mapper<UserGame>().mapArray(JSONArray: gamesArray)
      } else {
        err = UserManagerError.wrongResponse
      }
    }
  }

  func recentlyPlayedGames(userId: Int, completion: (([UserGame]?, Error?) -> ())?) {
    //Transforming into User Model
    self.provider.recentlyPlayedGamesData(with: userId) { (response, error) in
      var games: [UserGame]?
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
          games = Mapper<UserGame>().mapArray(JSONArray: gamesArray)
      } else {
        err = UserManagerError.wrongResponse
      }
    }
  }

  func level(userId: Int, completion: ((Int?, Error?) -> ())?) {
    self.provider.level(with: userId) { (response, error) in
      var level: Int?
      var err: Error?

      defer {
        completion?(level, err)
      }

      guard error == nil else {
        err = error
        return
      }

      if
        let response = response?["response"] as? [String: Int],
        let lev = response["player_level"] {
          level = lev
      } else {
        err = UserManagerError.wrongResponse
      }
    }
  }

  func statItems(userId: Int, gameId: Int, completion: ((Int?, Error?) -> ())?) {
    self.provider.level(with: userId) { (response, error) in
      var level: Int?
      var err: Error?

      defer {
        completion?(level, err)
      }
      
      guard error == nil else {
        err = error
        return
      }

      if
        let response = response?["response"] as? [String: Int],
        let lev = response["player_level"] {
          level = lev
      } else {
        err = UserManagerError.wrongResponse
      }
    }
  }

  func achievements(userId: Int, gameId: Int, completion: (([UserAchievement]?, Error?) -> ())?) {
    self.provider.achievementsData(with: userId, gameId: gameId) { (response, error) in

      var err: Error?
      var achievments: [UserAchievement]?

      defer {
        completion?(achievments, err)
      }

      if
        let response = response?["playerstats"] as? [String: Any],
        let data = response["achievements"] as? [[String: Any]] {
          achievments = Mapper<UserAchievement>().mapArray(JSONArray: data)
      } else {
        err = UserManagerError.wrongResponse
      }
    }
  }

}
