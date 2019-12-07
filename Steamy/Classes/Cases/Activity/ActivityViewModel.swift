//
//  ProfileViewModel.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import RxRelay

struct ActivityViewModelDependency {
  var userManager: UserManager
}

class ActivityViewModel: BaseViewModel, ViewModelProtocol {

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

  var input: ActivityViewModel.Input!
  var output: ActivityViewModel.Output!

  // MARK: -

  var userId: Int
  var dependencies: ActivityViewModelDependency

  init?(userId: Int, dependencies: ActivityViewModelDependency) {
    self.userId = userId
    self.dependencies = dependencies

    input = Input(didTapCell: didTapCellSubject.asObserver())
    output = Output(sections: sectionsRelay.asObservable(),
                    showController: showControllerSubject.asObservable())

    super.init()

    self.dependencies.userManager.recentlyPlayedGames(userId: userId) { [weak self] (userGames, error) in
      self?.games = userGames ?? []
      self?.createSections()
    }

    didTapCellSubject.asObserver().subscribe(onNext: { (indexPath) in
      guard let section = self.sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
        return
      }
      if section.identifier.starts(with: "ActivityCell") {
        //show
        guard
          let gameId = Int(section.identifier.split(separator: "_").last ?? ""),
          let userViewController = GameBuilder.gameViewController(with: userId, gameId: gameId) else {
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
    }).map { (game) -> ActivityCellItem in
      let gameCellItem = ActivityCellItem(reuseIdentifier: "ActivityCell",
                                          identifier: "ActivityCell_\(game.id ?? 0)")
      gameCellItem.gameName = game.name
      gameCellItem.gameIconURL = game.iconURL
      
      let playedTimeComponents = ((game.playtime2weeks ?? 0) * 60).secondsToHoursMinutesSeconds()
      var timePlayed = ""
      if (playedTimeComponents.0) > 0 {
        timePlayed += "\(playedTimeComponents.0) h."
      }
      if (playedTimeComponents.1) > 0 {
        if timePlayed != "" {
          timePlayed += " "
        }
        timePlayed += "\(playedTimeComponents.1) min"
      }
      if timePlayed != "" {
        timePlayed += " played"
      }
      gameCellItem.activityDesc = timePlayed
      return gameCellItem
    }
    if gameCells.count == 0 {
      let noGamesCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                      identifier: CellIdentifiers.noGames.rawValue)
      noGamesCell.title = "No Recent Games"
      gameCells.append(noGamesCell)
    }
    let section = BaseTableSectionItem(header: "RECENT GAMES", items: gameCells)
    sectionsRelay.accept([section])
  }
}
