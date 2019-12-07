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
  var statisticCollector: DataCollector
}

class ProfileViewModel: BaseViewModel, ViewModelProtocol {

  enum CellReuseIdentifiers: String {
    case showcase = "ShowcaseCell"
    case activity = "ActivityCell"
    case title = "TitleCell"
    case favoriteGame = "FavoriteGameCell"
  }

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
  var shouldShowFavoriteGame: Bool
  var favoriteGameid: Int?
  var dependencies: ProfileViewModelDependency

  init?(userId: Int,
        favoriteGameid: Int? = nil,
        shouldShowFavoriteGame: Bool = false,
        dependencies: ProfileViewModelDependency) {

    self.userId = userId
    self.favoriteGameid = favoriteGameid
    self.shouldShowFavoriteGame = shouldShowFavoriteGame
    self.dependencies = dependencies

    input = Input(didTapCell: didTapCellSubject.asObserver())
    output = Output(sections: sectionsRelay.asObservable(),
                    showController: showControllerSubject.asObservable())

    super.init()

    dependencies.userManager.games(userId: userId) { [weak self] (games, error) in
      self?.games = games ?? []
      self?.createSections()
      
      if (games?.filter({ (game) -> Bool in
        guard let gameId = game.id, let favoriteId = self?.favoriteGameid else {
          return false
        }
        return gameId == favoriteId
      }).count ?? 0) > 0 {
        self?.getStatistic()
      }
    }

    dependencies.userManager.badges(userId: userId) { [weak self] (badges, error) in
      self?.badgesCount = badges?.count ?? 0
      self?.createSections()
    }

    dependencies.userManager.friends(userId: userId) { [weak self] (users, error) in
      self?.friendsCount = users?.count ?? 0
      self?.createSections()
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

    if games.count > 0 && badgesCount != nil && friendsCount != nil {
      let totalPlayedComponents = (games.reduce(0, {(result: Int, item: UserGame) -> Int in
        return result + (item.playtime ?? 0)
      })*60).secondsToHoursMinutesSeconds()
      var totalPlayedString = ""
      if totalPlayedComponents.0 > 0 {
        totalPlayedString = "\(totalPlayedComponents.0) h"
      } else if totalPlayedComponents.1 > 0 {
        totalPlayedString += "\(totalPlayedComponents.1) min"
      } else {
        totalPlayedString = "0 h"
      }

      let totalPlayedCell = ShowcaseCellItem(reuseIdentifier: CellReuseIdentifiers.showcase.rawValue,
                                             identifier: "ShowcaseCell")
      totalPlayedCell.hoursPlayed = totalPlayedString
      totalPlayedCell.friendsCount = friendsCount ?? 0
      totalPlayedCell.badgesCount = badgesCount ?? 0
      totalPlayedCell.gamesCount = games.count
      var totalPlayedSection = BaseTableSectionItem(header: "ACHIEVEMENT SHOWCASE", items: [totalPlayedCell])
      totalPlayedSection.identifier = "TotalPlayedSection"
      sctns.append(totalPlayedSection)
    }

    //showing the first 3 games with the greatest playtime
    var gameCells: [BaseCellItem] = Array(games.sorted(by: { (game1, game2) -> Bool in
      return (game1.playtime ?? 0) > (game2.playtime ?? 0)
    })[safe: 0..<3] ?? []).map { (game) -> ActivityCellItem in
      let gameCellItem = ActivityCellItem(reuseIdentifier: CellReuseIdentifiers.activity.rawValue,
                                          identifier: "\(CellReuseIdentifiers.activity.rawValue)_\(game.id ?? 0)")
      gameCellItem.gameName = game.name
      gameCellItem.gameIconURL = game.iconURL
      let playedTimeComponents = ((game.playtime ?? 0) * 60).secondsToHoursMinutesSeconds()
      var timePlayed = ""
      if (playedTimeComponents.0) > 0 {
        timePlayed += "\(playedTimeComponents.0) h"
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
      let seeAllCell = TitleCellItem(reuseIdentifier: CellReuseIdentifiers.title.rawValue,
                                     identifier: CellIdentifiers.titleCellSeeAll.rawValue)
      seeAllCell.title = "See All Games"
      gameCells.append(seeAllCell)
    } else if self.games.count == 0 {
      let noGamesCell = TitleCellItem(reuseIdentifier: CellReuseIdentifiers.title.rawValue,
                                      identifier: CellIdentifiers.noGames.rawValue)
      noGamesCell.title = "No games yet"
      gameCells.append(noGamesCell)
    }

    if let favoriteGameid = favoriteGameid, shouldShowFavoriteGame {
      let favoriteGame = FavoriteGameCellItem(reuseIdentifier: CellReuseIdentifiers.favoriteGame.rawValue,
                                              identifier: "\(CellReuseIdentifiers.favoriteGame.rawValue)_\(favoriteGameid)")
      favoriteGame.image = UIImage(named: "favoriteGameLogo")
      var favoriteSection = BaseTableSectionItem(header: "FAVORITE GAME", items: [favoriteGame])
      favoriteSection.identifier = "FavoriteSection"
      sctns.append(favoriteSection)
    }

    var section = BaseTableSectionItem(header: "GAMES", items: gameCells)
    section.identifier = "GamesSection"
    sctns.append(section)
    sectionsRelay.accept(sctns)
  }

  // MARK: -

  func didTap(on indexPath: IndexPath) {
    guard let section = sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
      return
    }
    if section.identifier.starts(with: CellReuseIdentifiers.activity.rawValue) || section.identifier.starts(with: CellReuseIdentifiers.favoriteGame.rawValue) {
      //show
      guard
        let gameId = Int(section.identifier.split(separator: "_").last ?? "") else {
        return
      }
      let game = games.filter({ (game) -> Bool in
        return game.id == gameId
      }).first
      if let userViewController = GameBuilder.gameViewController(with: userId, gameId: gameId, timePlayed: game?.playtime) {
        showControllerSubject.onNext(userViewController)
      }
    } else if section.identifier == CellIdentifiers.titleCellSeeAll.rawValue {
      //show
      guard
        let userViewController = GameListBuilder.gameListViewController(with: userId) else {
        return
      }
      showControllerSubject.onNext(userViewController)
    }
  }

  // MARK: - CellItems

  // MARK: -

  func getStatistic() {
    if let favoriteGameid = favoriteGameid {
      self.dependencies.statisticCollector.collectData(userId: userId, gameId: favoriteGameid)
    }
  }
}
