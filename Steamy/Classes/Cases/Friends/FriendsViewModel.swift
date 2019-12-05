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
  }

  struct Output {
    var sections: Observable<[BaseTableSectionItem]>
    var showController: Observable<UIViewController>
  }

  var input: FriendsViewModel.Input!
  var output: FriendsViewModel.Output!

  init?(userId: Int, dependencies: FriendsViewModelDependency) {
    input = Input(didTapCell: didTapCellSubject.asObserver())
    output = Output(sections: sectionsRelay.asObservable(),
                    showController: showControllerSubject.asObservable())

    self.userId = userId
    self.dependency = dependencies

    super.init()

    self.dependency.userManager.friends(userId: userId) { [weak self] (users, error) in
      self?.users = users ?? []
      self?.createSections()
    }

    didTapCellSubject.asObserver().subscribe(onNext: { [weak self] (indexPath) in
      guard let section = self?.sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
        return
      }
      if section.identifier.starts(with: "FriendCell") {
        //show
        guard
          let userId = Int(section.identifier.split(separator: "_").last ?? ""),
          let userViewController = UserRouter.userViewController(with: userId) else {
          return
        }
        self?.showControllerSubject.onNext(userViewController)
      }
    }).disposed(by: disposeBag)
  }

  var userId: Int
  var dependency: FriendsViewModelDependency

  // MARK: -

  var users: [User] = []

  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])
  private var didTapCellSubject = PublishSubject<IndexPath>()
  private var showControllerSubject = PublishSubject<UIViewController>()

  // MARK: -

  func createSections() {
    var sctns = [BaseTableSectionItem]()

    var friendCells: [BaseCellItem] = self.users.map { (user) -> FriendCellItem in
      let friendCellItem = FriendCellItem(reuseIdentifier: "FriendCell",
                                          identifier: "FriendCell_\(user.steamid ?? 0)")
      friendCellItem.name = user.nickname
      friendCellItem.avatarURL = user.avatarURL
      return friendCellItem
    }
    if friendCells.count == 0 {
      let noFriendsCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                        identifier: "TitleCell_NoFriends")
      noFriendsCell.title = "No friends yet"
      friendCells.append(noFriendsCell)
    }
    let section = BaseTableSectionItem(header: "Friends", items: friendCells)
    sctns.append(section)
    sectionsRelay.accept(sctns)
  }
}
