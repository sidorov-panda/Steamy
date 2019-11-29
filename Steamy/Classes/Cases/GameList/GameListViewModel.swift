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

struct GameListViewModelDependency {
  var userManager: UserManager
}

class GameListViewModel: BaseViewModel, ViewModelProtocol {

  enum CellIdentifiers: String {
    case titleCellSeeAll
    case noGames
  }

  // MARK: - ViewModelProtocol

  struct Input {
    var didTapCell: AnyObserver<IndexPath>
  }

  struct Output {
    var sections: Observable<[BaseTableSectionItem]>
    var showController: Observable<UIViewController>
  }

  var input: GameListViewModel.Input!
  var output: GameListViewModel.Output!

  // MARK: -

  var userId: Int
  var dependencies: GameListViewModelDependency

  init?(userId: Int, dependencies: GameListViewModelDependency) {
    self.userId = userId
    self.dependencies = dependencies

    input = Input(didTapCell: didTapCellSubject.asObserver())
    output = Output(sections: sectionsRelay.asObservable(),
                    showController: showControllerSubject.asObservable())

    super.init()

    self.dependencies.userManager.games(userId: userId) { (games, error) in
      self.games = games ?? []
      self.createSections()
    }

    didTapCellSubject.asObserver().subscribe(onNext: { (indexPath) in
      guard let section = self.sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
        return
      }
      if section.identifier.starts(with: "GameCell") {
        //show
        guard
          let gameId = Int(section.identifier.split(separator: "_").last ?? ""),
          let userViewController = GameRouter.gameViewController(with: userId, gameId: gameId) else {
          return
        }
        self.showControllerSubject.onNext(userViewController)
      }
      }).disposed(by: disposeBag)
  }

  // MARK: -

  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])
  private var didTapCellSubject = PublishSubject<IndexPath>()
  private var showControllerSubject = PublishSubject<UIViewController>()

  // MARK: -

  var games: [UserGame] = []

  func createSections() {
    var sctns = [BaseTableSectionItem]()

    var gameCells: [BaseCellItem] = self.games.sorted(by: { (game1, game2) -> Bool in
      return (game1.playtime ?? 0) > (game2.playtime ?? 0)
    }).map { (game) -> GameCellItem in
      let gameCellItem = GameCellItem(reuseIdentifier: "GameCell", identifier: "GameCell_\(game.id ?? 0)")
      gameCellItem.name = game.name
      gameCellItem.logoURL = game.logoURL
      gameCellItem.iconURL = game.iconURL
      return gameCellItem
    }
    if gameCells.count == 0 {
      let noGamesCell = TitleCellItem(reuseIdentifier: "TitleCell", identifier: CellIdentifiers.noGames.rawValue)
      noGamesCell.title = "No games yet"
      gameCells.append(noGamesCell)
    }
    let section = BaseTableSectionItem(header: "Games", items: gameCells)
    sectionsRelay.accept([section])
  }
}