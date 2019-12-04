//
//  RootViewModel.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm

class RootViewModel: BaseViewModel, ViewModelProtocol {

  // MARK: - ViewModelProtocol

  struct Input {
    var didReceiveSteamUser: AnyObserver<String?>
    var viewDidLoad: AnyObserver<Void>
  }

  struct Output {
    var showLogin: Observable<Void>
    var showProfile: Observable<UIViewController?>
  }

  var input: RootViewModel.Input!
  var output: RootViewModel.Output!

  // MARK: -

  private var showLoginSubject = PublishSubject<Void>()
  private var viewDidLoadSubject = PublishSubject<Void>()
  private var didReceiveSteamUserSubject = BehaviorSubject<String?>(value: nil)
  private var showProfileSubject = PublishSubject<UIViewController?>()

  // MARK: -

  override init() {
    self.input = Input(didReceiveSteamUser: didReceiveSteamUserSubject.asObserver(),
                       viewDidLoad: viewDidLoadSubject.asObserver())
    self.output = Output(showLogin: showLoginSubject.asObservable(),
                         showProfile: showProfileSubject.asObservable())

    super.init()

    subscribe()
  }

  func subscribe() {
    didReceiveSteamUserSubject
      .asObservable()
      .filter({ (userIdString) -> Bool in
        userIdString != nil && (Int(userIdString!) ?? 0) > 0
      })
      .map({ (userIdString) -> Int in
        return Int(userIdString!)!
      })
      .subscribe(onNext: { [weak self] (userId) in
        Session.shared.userId = userId
        if let userViewController = UserRouter.userViewController(with: userId) {
          self?.showProfileSubject.onNext(UINavigationController(rootViewController: userViewController))
        }
      }).disposed(by: disposeBag)

    viewDidLoadSubject
      .asObservable()
      .subscribe(onNext: { [weak self] (_) in
        if
          let userId = Session.shared.userId,
          let userViewController = UserRouter.userViewController(with: userId) {
          self?.showProfileSubject.onNext(UINavigationController(rootViewController: userViewController))
        } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self?.showLoginSubject.onNext(())
          }
        }
      }).disposed(by: disposeBag)
  }
}
