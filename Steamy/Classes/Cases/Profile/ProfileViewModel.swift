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

struct ProfileViewModelDependency {
  var userManager: UserManager
}

class ProfileViewModel: BaseViewModel, ViewModelProtocol {

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

  var input: ProfileViewModel.Input!
  var output: ProfileViewModel.Output!

  // MARK: -

  var userId: Int
  var favoriteGameid: Int?
  var dependencies: ProfileViewModelDependency

  init?(userId: Int, favoriteGameid: Int? = nil, dependencies: ProfileViewModelDependency) {
    self.userId = userId
    self.favoriteGameid = favoriteGameid
    self.dependencies = dependencies

    input = Input(didTapCell: didTapCellSubject.asObserver())
    output = Output(sections: sectionsRelay.asObservable(),
                    showController: showControllerSubject.asObservable())

    super.init()

    self.dependencies.userManager.games(userId: userId) { (games, error) in
      self.games = games ?? []
      self.createSections()
    }

    didTapCellSubject.asObserver().subscribe(onNext: { [weak self] (indexPath) in
      self?.didTap(on: indexPath)
      }).disposed(by: disposeBag)
  }

  // MARK: -

  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])
  private var didTapCellSubject = PublishSubject<IndexPath>()
  private var showControllerSubject = PublishSubject<UIViewController>()

  // MARK: -

  var games: [UserGame] = []
  var friendsCount: Int?
  var badgesCount: Int?
  var groups: Int?

  func createSections() {
    var sctns = [BaseTableSectionItem]()

    if self.games.count > 0 {
      let totalPlayedComponents = (games.reduce(0, {(result: Int, item: UserGame) -> Int in
        return result + (item.playtime ?? 0)
      })*60).secondsToHoursMinutesSeconds()
      var totalPlayedString = ""
      if totalPlayedComponents.0 > 0 {
        totalPlayedString = "\(totalPlayedComponents.0) h."
      }
      if totalPlayedComponents.1 > 0 {
        if totalPlayedString != "" {
          totalPlayedString += " "
        }
        totalPlayedString += "\(totalPlayedComponents.1) min"
      }

      let totalPlayedCell = ShowcaseCellItem(reuseIdentifier: "ShowcaseCell", identifier: "ShowcaseCell")
      totalPlayedCell.hoursPlayed = totalPlayedString
      totalPlayedCell.friendsCount = 20
      let totalPlayedSection = BaseTableSectionItem(header: " ", items: [totalPlayedCell])
      sctns.append(totalPlayedSection)
    }

    //showing the first 3 games with the greatest playtime
    var gameCells: [BaseCellItem] = Array(self.games.sorted(by: { (game1, game2) -> Bool in
      return (game1.playtime ?? 0) > (game2.playtime ?? 0)
    })[safe: 0..<3] ?? []).map { (game) -> ActivityCellItem in
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
    if self.games.count > 3 {
      let seeAllCell = TitleCellItem(reuseIdentifier: "TitleCell", identifier: CellIdentifiers.titleCellSeeAll.rawValue)
      seeAllCell.title = "See All Games"
      gameCells.append(seeAllCell)
    } else if self.games.count == 0 {
      let noGamesCell = TitleCellItem(reuseIdentifier: "TitleCell", identifier: CellIdentifiers.noGames.rawValue)
      noGamesCell.title = "No games yet"
      gameCells.append(noGamesCell)
    }

    if let favoriteGameid = favoriteGameid {
      let favoriteGame = FavoriteGameCellItem(reuseIdentifier: "FavoriteGameCell",
                                              identifier: "FavoriteGame_\(favoriteGameid)")
      favoriteGame.image = UIImage(named: "favoriteGameLogo")
      let favoriteSection = BaseTableSectionItem(header: "FAVORITE GAME", items: [favoriteGame])
      sctns.append(favoriteSection)
    }

    let section = BaseTableSectionItem(header: "GAMES", items: gameCells)
    sctns.append(section)
    sectionsRelay.accept(sctns)
  }

  // MARK: -

  func didTap(on indexPath: IndexPath) {
    guard let section = self.sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
      return
    }
    if section.identifier.starts(with: "ActivityCell") || section.identifier.starts(with: "FavoriteGame") {
      //show
      guard
        let gameId = Int(section.identifier.split(separator: "_").last ?? ""),
        let userViewController = GameRouter.gameViewController(with: userId, gameId: gameId) else {
        return
      }
      self.showControllerSubject.onNext(userViewController)
    } else if section.identifier == CellIdentifiers.titleCellSeeAll.rawValue {
      //show
      guard
        let userViewController = GameListRouter.gameListViewController(with: userId) else {
        return
      }
      self.showControllerSubject.onNext(userViewController)
    }
  }
}
