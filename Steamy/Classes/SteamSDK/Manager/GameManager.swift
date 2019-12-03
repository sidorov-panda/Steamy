//
//  GameManager.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import ObjectMapper

protocol GameManagerProviderProtocol {
  typealias JSONObject = [String: Any]
  func gameData(with id: Int, completion: ((JSONObject?, Error?) -> ())?)
  func gameStatData(with id: Int, completion: ((JSONObject?, Error?) -> ())?)
}

class GameManagerSteamAPIProvider: GameManagerProviderProtocol {

  //Using HTTP as a transport
  let steamAPI = SteamAPI(httpClient: HTTPClient())

  func gameData(with id: Int, completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.gameInfo(gameId: id)) { (response, error) in
      completion?(response, error)
    }
  }

  func gameStatData(with id: Int, completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.gameSchema(gameId: id)) { (response, error) in
      completion?(response, error)
    }
  }
}

class GameManager {

  enum GameManagerError: Error {
    case wrongResponse
  }

  // MARK: -

  private var provider: GameManagerProviderProtocol

  init(provider: GameManagerProviderProtocol) {
    self.provider = provider
  }

  // MARK: - Methods

  func game(id: Int, completion: ((Game?, Error?) -> ())?) {
    self.provider.gameData(with: id) { (response, error) in
      var game: Game?
      var err: Error?

      defer {
        completion?(game, err)
      }

      guard
        let resp = response?[String(id)] as? [String: Any],
        let data = resp["data"] as? [String: Any],
        error == nil else {
        err = error
        return
      }

      game = Mapper<Game>().map(JSON: data)
    }
  }
  
  func gameStats(id: Int, completion: (([GameStat]?, [GameAchievement]?, Error?) -> ())?) {
    self.provider.gameStatData(with: id) { (response, error) in
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

      if
        let response = response?["game"] as? [String: Any],
        let gameStats = response["availableGameStats"] as? [String: Any] {

          if let userStats = gameStats["stats"] as? [[String: Any]] {
            stats = Mapper<GameStat>().mapArray(JSONArray: userStats)
          }

          if let achievements = gameStats["achievements"] as? [[String: Any]] {
            achiev = Mapper<GameAchievement>().mapArray(JSONArray: achievements)
          }
      } else {
        err = GameManagerError.wrongResponse
      }
    }
  }
}
