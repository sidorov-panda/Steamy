//
//  UserManager.swift
//  Steamy
//
//  Created by Alexey Sidorov on 22.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

/// Class is used to manage User's data
class UserManager: BaseManager {

  enum UserManagerError: Error {
    case noUser
    case noUserIds
    case wrongResponse
  }

  // MARK: -

  private var provider: UserManagerProviderProtocol

  init(provider: UserManagerProviderProtocol) {
    self.provider = provider
  }

  // MARK: - Methods

  func badges(userId: Int, completion: (([Badge]?, Error?) -> ())?) {
    self.provider.badges(with: userId) { (response, error) in
      var badges: [Badge]?
      var err: Error?

      defer {
        completion?(badges, err)
      }

      guard let resp = response else {
        err = UserManagerError.wrongResponse
        return
      }
      badges = Mapper<Badge>().mapArray(JSONArray: resp)
    }
  }

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

  func users(ids: [Int], completion: (([User]?, Error?) -> ())?) {
    //Transforming into User Model
    self.provider.usersData(with: ids) { (response, error) in
      var users: [User]?
      var err: Error?

      defer {
        completion?(users, err)
      }

      guard error == nil else {
        err = error
        return
      }

      if
        let response = response?["response"] as? [String: Any],
        let usersArray = response["players"] as? [[String: Any]] {
          users = Mapper<User>().mapArray(JSONArray: usersArray)
      } else {
        err = UserManagerError.wrongResponse
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

  func gameStats(userId: Int, gameId: Int, completion: (([GameStat]?, [GameAchievement]?, Error?) -> ())?) {
    self.provider.gameStatsData(with: userId, gameId: gameId) { (response, error) in
      var stats: [GameStat]?
      var achiev: [GameAchievement]?
      var err: Error?

      defer {
        completion?(stats, achiev, err)
      }

      guard error == nil else {
        err = error
        return
      }

      if let response = response?["playerstats"] as? [String: Any] {
        if let userStats = response["stats"] as? [[String: Any]] {
          stats = Mapper<GameStat>().mapArray(JSONArray: userStats)
        }

        if let achievements = response["achievements"] as? [[String: Any]] {
          achiev = Mapper<GameAchievement>().mapArray(JSONArray: achievements)
        }
      } else {
        err = UserManagerError.wrongResponse
      }
    }
  }

  func achievements(userId: Int, gameId: Int, completion: (([GameAchievement]?, Error?) -> ())?) {
    self.provider.achievementsData(with: userId, gameId: gameId) { (response, error) in
      var err: Error?
      var achievments: [GameAchievement]?

      defer {
        completion?(achievments, err)
      }

      if
        let response = response?["playerstats"] as? [String: Any],
        let data = response["achievements"] as? [[String: Any]] {
          achievments = Mapper<GameAchievement>().mapArray(JSONArray: data)
      } else {
        err = UserManagerError.wrongResponse
      }
    }
  }

  func friends(userId: Int, completion: (([User]?, Error?) -> ())?) {
    self.provider.friends(with: userId) { (response, error) in
      guard
        let friendlist = response?["friendslist"] as? [String: Any],
        let friends = friendlist["friends"] as? [[String: Any]] else {
          completion?(nil, UserManagerError.wrongResponse)
          return
      }

      let userIds = friends.filter ({ (friendDict) -> Bool in
        return ((friendDict["relationship"] as? String) ?? "") == "friend"
      }).map { (friendDict) -> Int? in
        return Int((friendDict["steamid"] as? String) ?? "")
      }.filter { (val) -> Bool in
        return val != nil
      } as? [Int] ?? []

      guard userIds.count > 0 else {
        completion?(nil, UserManagerError.noUserIds)
        return
      }
      //Not the best solution, but for simplicity purposes
      self.users(ids: userIds) { (usersResponse, usersError) in
        guard usersError == nil else {
          completion?(usersResponse, usersError)
          return
        }
        completion?(usersResponse, nil)
      }
    }
  }
}
