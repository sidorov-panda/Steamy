//
//  GameManager+Rx.swift
//  Steamy
//
//  Created by Alexey Sidorov on 29.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift

extension GameManager {

  func gameStats(id: Int) -> Observable<([GameStat], [GameAchievement])> {
    return Observable.create { (observer) -> Disposable in
      self.gameStats(id: id) { (gameStats, achievements, error) in
        if let err = error {
          observer.onError(err)
        } else {
          //check if parse error?
          observer.onNext((gameStats ?? [], achievements ?? []))
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }

  func game(id: Int) -> Observable<Game?> {
    return Observable.create { (observer) -> Disposable in
      self.game(id: id) { (game, error) in
        if let err = error {
          observer.onError(err)
        } else {
          //check if parse error?
          observer.onNext(game)
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }
}
