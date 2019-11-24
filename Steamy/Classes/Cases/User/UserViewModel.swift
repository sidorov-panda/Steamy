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

  // MARK: -

  var userId: Int

  init?(userId: Int, dependencies: UserViewModelDependency) {
    self.userId = userId
    self.dependencies = dependencies

    super.init()

    self.input = Input()
    self.output = Output(userInfoItem: self.userInfoViewItem)

    loadUserData()
  }

  private func loadUserData() {
    self.dependencies.userManager.user(id: Session.shared.userId!) { (user, error) in
      print(user)
      print(error)

      if let user = user {
        self.nameSubject.onNext(user.nickname)
        self.locationSubject.onNext(user.countryCode)
        self.avatarSubject.onNext(user.avatarURL)
      }
    }

    self.dependencies.userManager.games(userId: Session.shared.userId!) { (games, error) in
      print(games)
      print(error)
    }

    self.dependencies.userManager.recentlyPlayedGames(userId: Session.shared.userId!) { (games, error) in
      print(games)
      print(error)
    }

    self.dependencies.userManager.level(userId: Session.shared.userId!) { (level, error) in
      print(level)
      print(error)

      if let level = level {
        self.levelSubject.onNext(String(level) + " level")
      }
    }
  }
}
