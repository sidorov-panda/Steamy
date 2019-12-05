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
    
  }

  struct Output {
    var userInfoItem: () -> (UserInfoViewItem)
    var userPages: () -> ([UIViewController])
  }

  var input: UserViewModel.Input!
  var output: UserViewModel.Output!
  var dependencies: UserViewModelDependency!

  // MARK: -

  private var nameSubject = PublishSubject<String?>()
  private var locationSubject = PublishSubject<String?>()
  private var levelSubject = PublishSubject<String?>()
  private var avatarSubject = PublishSubject<URL?>()

  func userInfoViewItem() -> UserInfoViewItem {
    return UserInfoViewItem(nameObservable: self.nameSubject.asObservable(),
                            locationObservable: self.locationSubject.asObservable(),
                            levelObservable: self.levelSubject.asObservable(),
                            avatarObservable: self.avatarSubject.asObservable())
  }

  func userViewControllers() -> [UIViewController] {
    guard
      let profileVC = ProfileRouter.profileViewController(with: userId),
      let friendsVC = FriendsRouter.friendsViewController(with: userId),
      let activityVC = ActivityRouter.activityViewController(with: userId)
    else {
      return []
    }
    return [profileVC, activityVC, friendsVC]
  }

  // MARK: -

  var userId: Int

  init?(userId: Int, dependencies: UserViewModelDependency) {
    self.userId = userId
    self.dependencies = dependencies

    super.init()

    self.input = Input()
    self.output = Output(userInfoItem: self.userInfoViewItem,
                         userPages: self.userViewControllers)

    loadUserData()
  }

  private func loadUserData() {
    self.dependencies.userManager.user(id: userId) { [weak self] (user, error) in
      if let user = user {
        if
          let countryCode = user.countryCode {
          let geo = Geo(countryCode: countryCode, stateCode: user.stateCode, cityCode: String(user.cityCode ?? 0))
          var location = geo.countryName ?? ""
          if let cityName = geo.cityName {
            location += ", \(cityName)"
          }
          self?.locationSubject.onNext(location)
        }
        self?.nameSubject.onNext(user.nickname)
        self?.avatarSubject.onNext(user.avatarURL)
      }
    }

    self.dependencies.userManager.level(userId: userId) { (level, error) in
      if let level = level {
        self.levelSubject.onNext(String(level) + " level")
      }
    }
  }
}
