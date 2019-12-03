//
//  UserManager+Rx.swift
//  Steamy
//
//  Created by Alexey Sidorov on 30.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift

extension UserManager {

  func achievements(userId: Int, gameId: Int) -> Observable<[GameAchievement]> {
    return Observable.create { (observer) -> Disposable in
      self.achievements(userId: userId, gameId: gameId, completion: { achievements, error in
        if let err = error {
          observer.onError(err)
        } else {
          //check if parse error?
          observer.onNext(achievements ?? [])
          observer.onCompleted()
        }
      })
      return Disposables.create()
    }
  }

  func gameStats(userId: Int, gameId: Int) -> Observable<([GameStat], [GameAchievement])> {
    return Observable.create { (observer) -> Disposable in
      self.gameStats(userId: userId, gameId: gameId) { (stats, achievements, error) in
        if let err = error {
          observer.onError(err)
        } else {
          //check if parse error?
          observer.onNext((stats ?? [], achievements ?? []))
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }

}
