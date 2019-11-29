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
      let friendsVC = FriendsRouter.friendsViewController(with: userId)
    else {
      return []
    }
    return [profileVC, ActivityViewController(), friendsVC, ProfileViewController(), ProfileViewController()]
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
    self.dependencies.userManager.user(id: userId) { (user, error) in
      if let user = user {
        self.nameSubject.onNext(user.nickname)
        self.locationSubject.onNext(user.countryCode)
        self.avatarSubject.onNext(user.avatarURL)
      }
    }

//    self.dependencies.userManager.games(userId: Session.shared.userId!) { (games, error) in
//      print(games)
//      print(error)
//    }

//    self.dependencies.userManager.recentlyPlayedGames(userId: Session.shared.userId!) { (games, error) in
//      print(games)
//      print(error)
//    }

    self.dependencies.userManager.level(userId: userId) { (level, error) in
      print(level)
      print(error)

      if let level = level {
        self.levelSubject.onNext(String(level) + " level")
      }
    }
  }
}
