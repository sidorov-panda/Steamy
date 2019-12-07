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
    var searchTerm: AnyObserver<String?>
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

    input = Input(didTapCell: didTapCellSubject.asObserver(),
                  searchTerm: searchTermSubject.asObserver())
    output = Output(sections: sectionsRelay.asObservable(),
                    showController: showControllerSubject.asObservable())

    super.init()

    self.dependencies.userManager.games(userId: userId) { (games, error) in
      self.games = games ?? []
      self.createSections()
    }

    bind()
  }

  // MARK: -

  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])
  private var didTapCellSubject = PublishSubject<IndexPath>()
  private var showControllerSubject = PublishSubject<UIViewController>()
  private var searchTermSubject = BehaviorSubject<String?>(value: nil)

  // MARK: -

  func bind() {
    didTapCellSubject.asObserver().subscribe(onNext: { [weak self] (indexPath) in
      self?.didTap(on: indexPath)
    }).disposed(by: disposeBag)

    searchTermSubject.asObserver().subscribe(onNext: { [weak self] (term) in
      self?.createSections()
    }).disposed(by: disposeBag)

  }

  func didTap(on indexPath: IndexPath) {
    guard let section = sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
      return
    }
    if section.identifier.starts(with: "GameCell") {
      //show
      guard
        let gameId = Int(section.identifier.split(separator: "_").last ?? ""),
        let game = games.filter({ (game) -> Bool in
          return game.id == gameId
          }).first,
        let userViewController = GameBuilder.gameViewController(with: userId, gameId: gameId, timePlayed: game.playtime) else {
        return
      }
      self.showControllerSubject.onNext(userViewController)
    }
  }

  // MARK: -

  var games: [UserGame] = []

  func createSections() {
    var gameCells: [BaseCellItem] = self.games.filter({ (game) -> Bool in
      if let term = try! self.searchTermSubject.value()?.lowercased(), term.count > 0 {
        return (game.name ?? "").lowercased().contains(term)
      }
      return true
    }).sorted(by: { (game1, game2) -> Bool in
      return (game1.playtime ?? 0) > (game2.playtime ?? 0)
    }).map { (game) -> GameCellItem in
      let gameCellItem = GameCellItem(reuseIdentifier: "GameCell",
                                      identifier: "GameCell_\(game.id ?? 0)")
      gameCellItem.name = game.name
      gameCellItem.logoURL = game.logoURL
      gameCellItem.iconURL = game.iconURL
      return gameCellItem
    }
    if gameCells.count == 0 {
      let noGamesCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                      identifier: CellIdentifiers.noGames.rawValue)
      noGamesCell.title = "No games found"
      gameCells.append(noGamesCell)
    }
    var section = BaseTableSectionItem(header: "Games", items: gameCells)
    section.identifier = "GameSection"
    sectionsRelay.accept([section])
  }
}
