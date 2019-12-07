//
//  SteamAPI.swift
//  SteamyTests
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import XCTest
@testable import Steamy

class TestHttpClient: HTTPClientProtocol {
  func getRequest(_ url: URL, params: [String : Any], refresh: Bool, completion: @escaping ((TestHttpClient.HTTPClientResponse) -> ())) {}
  func postRequest(_ url: URL, params: [String : Any], completion: ((TestHttpClient.HTTPClientResponse) -> ())) {}
}

class SteamAPITests: XCTestCase {

  override func setUp() {}

  override func tearDown() {}

  // MARK: -

  func testAPIUserURL() {
    XCTAssert(SteamAPI.Method.user(id: 1).url()?.absoluteString == "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=100170AD8C821B6B6948EA460DD9F89D&format=json&steamids=1")
  }

  func testAPIUsersURL() {
    XCTAssert(SteamAPI.Method.users(ids: [1,2]).url()?.absoluteString == "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=100170AD8C821B6B6948EA460DD9F89D&format=json&steamids=1,2")
  }

  func testAPIOwnedGames() {
    XCTAssert(SteamAPI.Method.ownedGames(userId: 1).url()?.absoluteString == "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=100170AD8C821B6B6948EA460DD9F89D&format=json&steamid=1&include_played_free_games=1&include_appinfo=1")
  }

  func testAPIFullGame() {
    XCTAssert(SteamAPI.Method.gameInfo(gameId: 570).url()?.absoluteString == "https://store.steampowered.com/api/appdetails//?key=100170AD8C821B6B6948EA460DD9F89D&format=json&appids=570")
  }

}
