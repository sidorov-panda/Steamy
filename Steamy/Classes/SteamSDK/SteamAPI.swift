//
//  SteamAPI.swift
//  Steamy
//
//  Created by Alexey Sidorov on 22.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

fileprivate let SteamAPIBaseURLString = "http://api.steampowered.com"
fileprivate let SteamStoreAPIBaseURLString = "https://store.steampowered.com"
fileprivate let SteamAPIKey = "100170AD8C821B6B6948EA460DD9F89D"//"85C8BD436F4D49C79B574B6BAD2D23C6"

class SteamAPI {

  // MARK: -

  typealias Response = [String: Any]

  private let httpClient: HTTPClientProtocol

  init(httpClient: HTTPClientProtocol) {
    self.httpClient = httpClient
  }

  // MARK: -

  enum SteamAPIError: Error {
    case noURLForMethod
  }

  enum Method {
    case user(id: Int)
    case users(ids: [Int])
    case friends(userId: Int)
    case userLevel(id: Int)
    case ownedGames(userId: Int)
    case recentlyPlayedGames(userId: Int)
    case gameStats(userId: Int, gameId: Int)
    case gameInfo(gameId: Int)
    case gameSchema(gameId: Int)
    case achievements(userId: Int, gameId: Int)
    case badges(userId: Int)
    case news(gameId: Int)

    func url() -> URL? {
      var components: URLComponents?
      switch self {
      case .gameInfo(_):
        components = URLComponents(string: SteamStoreAPIBaseURLString)
      default:
        components = URLComponents(string: SteamAPIBaseURLString)
      }

      components?.path = self.URLPath()
      components?.queryItems = self.queryItems()
      return components?.url
    }

    private func URLPath() -> String {
      var path = "/"
      switch self {
      case .user(_), .users(_):
        path += "ISteamUser/GetPlayerSummaries"
        break

      case .ownedGames(_):
        path += "IPlayerService/GetOwnedGames"
        break

      case .recentlyPlayedGames(_):
        path += "IPlayerService/GetRecentlyPlayedGames"
        break

      case .userLevel(_):
        path += "IPlayerService/GetSteamLevel"
        break

      case .gameStats(_, _):
        path += "ISteamUserStats/GetUserStatsForGame"
        break

      case .gameSchema(_):
        path += "ISteamUserStats/GetSchemaForGame"
        break

      case .gameInfo(_):
        path += "api/appdetails"
        break

      case .achievements(_, _):
        path += "ISteamUserStats/GetPlayerAchievements"
        break

      case .friends(_):
        path += "ISteamUser/GetFriendList"
        break

      case .badges(_):
        path += "IPlayerService/GetBadges"
        break
      case .news(_):
        path += "ISteamNews/GetNewsForApp"
        break
      }
      path.append("/\(self.APIVersion())/")
      return path
    }

    private func APIVersion() -> String {
      switch self {
      case .user(_), .users(_), .gameStats(_, _), .news(_):
        return "v0002"
      case .gameSchema(_):
        return "v2"
      case .ownedGames(_), .achievements(_, _), .recentlyPlayedGames(_), .friends(_):
        return "v0001"
      case .userLevel(_), .badges(_):
        return "v1"
      case .gameInfo(_):
        return ""
      }
    }

    private func queryItems() -> [URLQueryItem] {
      var ret = [URLQueryItem]()
      ret.append(URLQueryItem(name: "key", value: SteamAPIKey))
      ret.append(URLQueryItem(name: "format", value: "json"))

      switch self {
      case .user(let id):
        ret.append(URLQueryItem(name: "steamids", value: String(id)))

      case .users(let ids):
        ret.append(
          URLQueryItem(name: "steamids", value: Array(Set(ids)).sorted().map { String($0) }.joined(separator: ","))
        )

      case .ownedGames(let userId):
        ret.append(URLQueryItem(name: "steamid", value: String(userId)))
        ret.append(URLQueryItem(name: "include_played_free_games", value: "1"))
        ret.append(URLQueryItem(name: "include_appinfo", value: "1"))

      case .recentlyPlayedGames(let userId):
        ret.append(URLQueryItem(name: "steamid", value: String(userId)))

      case .userLevel(let id):
        ret.append(URLQueryItem(name: "steamid", value: String(id)))

      case .gameStats(let userId, let gameId):
        ret.append(URLQueryItem(name: "steamid", value: String(userId)))
        ret.append(URLQueryItem(name: "appid", value: String(gameId)))

      case .gameSchema(let gameId):
        ret.append(URLQueryItem(name: "appid", value: String(gameId)))

      case .gameInfo(let gameId):
        ret.append(URLQueryItem(name: "appids", value: String(gameId)))

      case .achievements(let userId, let gameId):
        ret.append(URLQueryItem(name: "steamid", value: String(userId)))
        ret.append(URLQueryItem(name: "appid", value: String(gameId)))

      case .friends(let userId):
        ret.append(URLQueryItem(name: "steamid", value: String(userId)))

      case .badges(let userId):
        ret.append(URLQueryItem(name: "steamid", value: String(userId)))
        
      case .news(let gameId):
        ret.append(URLQueryItem(name: "appid", value: String(gameId)))
      }
      return ret
    }
  }

  func request(_ method: Method, params: [String: Any] = [:], refresh: Bool = false, completion: ((Response?, Error?) -> ())?) {
    var response: Response?
    var error: Error?

    guard let url = method.url() else {
      error = SteamAPIError.noURLForMethod
      completion?(response, error)
      return
    }

    self.httpClient.getRequest(url, params: params, refresh: refresh) { (response) in
      completion?(response.0 as? Response, response.1)
    }
  }
}
