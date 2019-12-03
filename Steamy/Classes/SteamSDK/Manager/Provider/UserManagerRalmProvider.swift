//
//  UserManagerRalmProvider.swift
//  Steamy
//
//  Created by Alexey Sidorov on 29.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RealmSwift

class UserManagerRealmProvider: UserManagerProviderProtocol {

  private let realm = try! Realm()

  func userData(with userid: Int, completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    
  }

  func usersData(with ids: [Int], completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    let objects = realm.objects(UserDB.self).toArray().filter { (user) -> Bool in
      //HACK since Realm doesn't support list queries yet
      guard let intId = Int((user.steamidPk ?? "")) else {
        return false
      }
      return ids.contains(intId)
    }
    let users = objects.map { (userDbObj) -> [String: Any?] in
      return [
        "steamid": userDbObj.steamidPk ?? "",
        "avatarfull": userDbObj.avatarURL ?? "",
        "realname": userDbObj.name,
        "personaname": userDbObj.nickname,
        "loccountrycode": userDbObj.countryCode,
        "locstatecode": userDbObj.stateCode,
        "loccityid": userDbObj.cityCode.value
      ]
    }
    let resp = ["response": ["players": users]]
    completion?(resp, nil)
  }

  func ownedGamesData(with userId: Int, completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    
  }

  func recentlyPlayedGamesData(with userId: Int, completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    
  }

  func level(with userId: Int, completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    
  }

  func achievementsData(with userId: Int, gameId: Int, completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    
  }

  func gameStatsData(with userId: Int, gameId: Int, completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    
  }

  func friends(with userId: Int, completion: ((UserManagerRealmProvider.JSONObject?, Error?) -> ())?) {
    let objects = realm.objects(FriendDB.self).filter("userId=%@", String(userId))
    let users =  objects.toArray().map { (userDb) -> [String: Any] in
      return [
        "steamid": userDb.steamidPk ?? "",
        "relationship": "friend"
      ]
    }
    let resp = ["friendslist": ["friends": users]]
    completion?(resp, nil)
  }

  func badges(with userId: Int, completion: (([UserManagerRealmProvider.JSONObject]?, Error?) -> ())?) {
    
  }

}
