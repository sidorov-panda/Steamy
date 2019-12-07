//
//  ProfileViewModel.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

struct FriendsViewModelDependency {
  var userManager: UserManager
}

class FriendsViewModel: BaseViewModel, ViewModelProtocol {

  // MARK: - ViewModelProtocol

  struct Input {
    var didTapCell: AnyObserver<IndexPath>
    var viewWillAppear: AnyObserver<Bool>
  }

  struct Output {
    var sections: Observable<[BaseTableSectionItem]>
    var showController: Observable<UIViewController>
  }

  var input: FriendsViewModel.Input!
  var output: FriendsViewModel.Output!

  init?(userId: Int, dependencies: FriendsViewModelDependency) {
    input = Input(didTapCell: didTapCellSubject.asObserver(),
                  viewWillAppear: viewWillAppearSubject.asObserver())
    output = Output(sections: sectionsRelay.asObservable(),
                    showController: showControllerSubject.asObservable())

    self.userId = userId
    self.dependency = dependencies

    super.init()

    loadFriends()

    bind()
  }

  var userId: Int
  var dependency: FriendsViewModelDependency

  // MARK: -

  var users: [User] = []

  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])
  private var didTapCellSubject = PublishSubject<IndexPath>()
  private var showControllerSubject = PublishSubject<UIViewController>()
  private var viewWillAppearSubject = PublishSubject<Bool>()

  // MARK: - Binding

  private func bind() {
    viewWillAppearSubject.subscribe(onNext: { [weak self] (_) in
      self?.loadFriends()
    }).disposed(by: disposeBag)

    didTapCellSubject.asObserver().subscribe(onNext: { [weak self] (indexPath) in
      self?.didTapCell(on: indexPath)
    }).disposed(by: disposeBag)
  }

  // MARK: - Sections

  func createSections() {
    var sctns = [BaseTableSectionItem]()

    let onlineFriendCells: [BaseCellItem] = users.sorted(by: { (user1, user2) -> Bool in
      return (user1.nickname ?? user1.name ?? "") > (user2.nickname ?? user2.name ?? "")
    }).filter({ (user) -> Bool in
      return
      (user.personastate == .online
        || user.personastate == .lookingToPlay
        || user.personastate == .busy
        || user.personastate == .away
        || user.personastate == .lookingToTrade
        || user.personastate == .snooze)
    }).map { (user) -> FriendCellItem in
      let friendCellItem = FriendCellItem(reuseIdentifier: "FriendCell",
                                          identifier: "FriendCell_\(user.steamid ?? 0)")
      friendCellItem.name = (user.nickname ?? user.name ?? "") + (user.visibilityState == .notVisible ? "🔒" : "")
      friendCellItem.avatarURL = user.avatarURL
      return friendCellItem
    }

    let offlineFriendCells: [BaseCellItem] = users.filter({ (user) -> Bool in
      return user.personastate == .offline
    }).sorted(by: { (user1, user2) -> Bool in
      return (user1.nickname ?? user1.name ?? "") > (user2.nickname ?? user2.name ?? "")
    }).map { (user) -> FriendCellItem in
      let friendCellItem = FriendCellItem(reuseIdentifier: "FriendCell",
                                          identifier: "FriendCell_\(user.steamid ?? 0)")
      friendCellItem.name = (user.nickname ?? user.name ?? "") + (user.visibilityState == .notVisible ? "🔒" : "")
      friendCellItem.avatarURL = user.avatarURL
      return friendCellItem
    }

    if onlineFriendCells.count == 0 && offlineFriendCells.count == 0 {
      let noFriendsCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                        identifier: "TitleCell_NoFriends")
      noFriendsCell.title = "No friends yet"
      var section = BaseTableSectionItem(header: "Friends", items: [noFriendsCell])
      section.identifier = "FriendsSection"
      sctns.append(section)
    }
    if onlineFriendCells.count > 0 {
      var section = BaseTableSectionItem(header: "Online", items: onlineFriendCells)
      section.identifier = "FriendsSectionOnline"
      sctns.append(section)
    }
    
    if offlineFriendCells.count > 0 {
      var section = BaseTableSectionItem(header: "Offline", items: offlineFriendCells)
      section.identifier = "FriendsSectionOffline"
      sctns.append(section)
    }
    sectionsRelay.accept(sctns)
  }

  // MARK: -

  func didTapCell(on indexPath: IndexPath) {
    guard let section = sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
      return
    }
    if section.identifier.starts(with: "FriendCell") {
      //show
      guard
        let userId = Int(section.identifier.split(separator: "_").last ?? ""),
        let userViewController = UserBuilder.userViewController(with: userId) else {
        return
      }
      showControllerSubject.onNext(userViewController)
    }
  }

  // MARK: - Load

  var isLoading = false

  func loadFriends() {
    guard !isLoading else { return }
    isLoading = true
    self.dependency.userManager.friends(userId: userId) { [weak self] (users, error) in
      self?.users = users ?? []
      self?.isLoading = false
      self?.createSections()
    }
  }
}
