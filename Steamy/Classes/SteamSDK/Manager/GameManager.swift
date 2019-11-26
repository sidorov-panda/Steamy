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
}

class GameManagerSteamAPIProvider: GameManagerProviderProtocol {

  //Using HTTP as a transport
  let steamAPI = SteamAPI(httpClient: HTTPClient())

  func gameData(with id: Int, completion: ((JSONObject?, Error?) -> ())?) {
    steamAPI.request(.gameInfo(gameId: id)) { (response, error) in
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
}
