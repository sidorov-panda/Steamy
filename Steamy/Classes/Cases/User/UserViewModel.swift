//
//  UserViewModel.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift

struct UserViewModelDependency {
  var userManager: UserManager
}

class UserViewModel: BaseViewModel, ViewModelProtocol {

  // MARK: - ViewModelProtocol

  struct Input {
    var viewDidLoad: AnyObserver<Void>
  }

  struct Output {
    var userInfoItem: () -> (UserInfoViewItem)
    var userPages: () -> ([UIViewController])
  }

  var input: UserViewModel.Input!
  var output: UserViewModel.Output!
  var dependencies: UserViewModelDependency!

  // MARK: -

  private var viewDidLoadSubject = PublishSubject<Void>()
  private var nameSubject = PublishSubject<String?>()
  private var locationSubject = PublishSubject<String?>()
  private var levelSubject = PublishSubject<String?>()
  private var avatarSubject = PublishSubject<URL?>()
  private var onlineSubject = PublishSubject<Bool>()

  func userInfoViewItem() -> UserInfoViewItem {
    return UserInfoViewItem(nameObservable: self.nameSubject.asObservable(),
                            locationObservable: self.locationSubject.asObservable(),
                            levelObservable: self.levelSubject.asObservable(),
                            avatarObservable: self.avatarSubject.asObservable(),
                            onlineObservable: self.onlineSubject.asObservable())
  }

  func userViewControllers() -> [UIViewController] {
    guard
      let profileVC = ProfileBuilder.profileViewController(with: userId),
      let friendsVC = FriendsBuilder.friendsViewController(with: userId),
      let activityVC = ActivityBuilder.activityViewController(with: userId)
    else {
      return []
    }
    return [profileVC, activityVC, friendsVC]
  }

  // MARK: -

  var userId: Int
  var user: User?

  init?(userId: Int, dependencies: UserViewModelDependency) {
    self.userId = userId
    self.dependencies = dependencies

    super.init()

    self.input = Input(viewDidLoad: viewDidLoadSubject.asObserver())
    self.output = Output(userInfoItem: self.userInfoViewItem,
                         userPages: self.userViewControllers)
    bind()
    loadUserData()
  }

  init?(user: User, dependencies: UserViewModelDependency) {
    guard let userId = user.steamid else {
      return nil
    }

    self.userId = userId
    self.user = user

    self.dependencies = dependencies

    super.init()

    self.input = Input(viewDidLoad: viewDidLoadSubject.asObserver())
    self.output = Output(userInfoItem: self.userInfoViewItem,
                         userPages: self.userViewControllers)

    bind()
  }

  func bind() {
    viewDidLoadSubject.asObservable().subscribe(onNext: { [weak self] (_) in
      if let user = self?.user {
        self?.setUser(user)
      }
    }).disposed(by: disposeBag)

    loadUserData()
  }

  private func loadUserData() {
    self.dependencies.userManager.user(id: userId) { [weak self] (user, error) in
      if let user = user {
        self?.setUser(user)
      }
    }

    self.dependencies.userManager.level(userId: userId) { (level, error) in
      if let level = level {
        self.levelSubject.onNext(String(level) + " LEVEL")
      }
    }
  }

  func setUser(_ user: User) {
    if
      let countryCode = user.countryCode {
      let geo = Geo(countryCode: countryCode, stateCode: user.stateCode, cityCode: String(user.cityCode ?? 0))
      var location = geo.countryName ?? ""
      if let cityName = geo.cityName {
        location += ", \(cityName)"
      }
      locationSubject.onNext(location)
    }
    let name = (user.nickname ?? user.name ?? "") + (user.visibilityState == .notVisible ? "🔒" : "")
    nameSubject.onNext(name)
    avatarSubject.onNext(user.avatarURL)
    onlineSubject.onNext(user.personastate != .offline)
  }

}
