//
//  GameViewModel.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import ImageSlideshow

struct GameViewModelDependency {
  var userManager: UserManager
  var gameManager: GameManager
  var statisticProvider: StatisticsProvider?
}

protocol StatisticsProvider: class {
  func statistics(for userId: Int) -> [Date: [String: (String?, Int)]]
}

class GameViewModel: BaseViewModel, ViewModelProtocol {

  // MARK: -

  struct Input {
    var viewDidLoad: AnyObserver<Void>
    var didTapCell: AnyObserver<IndexPath>
  }

  struct Output {
    var headerImage: Observable<URL?>
    var title: Observable<String?>
    var isLoading: Observable<Bool>
    var sections: Observable<[BaseTableSectionItem]>
    var images: Observable<[InputSource]>
  }

  var input: GameViewModel.Input!
  var output: GameViewModel.Output!

  // MARK: -

  private var headerImageSubject = PublishSubject<URL?>()
  private var titleSubject = PublishSubject<String?>()
  private var isLoadingSubject = PublishSubject<Bool>()
  private var viewDidLoadSubject = PublishSubject<Void>()
  private var imagesSubject = PublishSubject<[InputSource]>()
  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])
  private var didTapCellSubject = PublishSubject<IndexPath>()

  // MARK: -

  var achievementsOnPage = 3
  var statsOnPage = 3

  var shouldShowAllAchievements = false
  var shouldShowAllStats = false

  var dependencies: GameViewModelDependency
  var gameId: Int
  var userId: Int
  var game: Game?
  var isFavoriteGame: Bool

  var achievments: [GameAchievement] = []
  var userStats: [GameStat] = []

  init?(userId: Int, gameId: Int, isFavoriteGame: Bool = false, dependencies: GameViewModelDependency) {
    self.userId = userId
    self.gameId = gameId
    self.isFavoriteGame = isFavoriteGame
    self.dependencies = dependencies

    super.init()

    self.input = Input(viewDidLoad: viewDidLoadSubject.asObserver(),
                       didTapCell: didTapCellSubject.asObserver())
    self.output = Output(headerImage: headerImageSubject.asObservable(),
                         title: titleSubject.asObservable(),
                         isLoading: isLoadingSubject.asObservable(),
                         sections: sectionsRelay.asObservable(),
                         images: imagesSubject.asObservable())

    viewDidLoadSubject.subscribe(onNext: { [weak self] (_) in
      self?.isLoadingSubject.onNext(true)
      self?.getGameInfo()
      self?.getAchievements()
    }).disposed(by: disposeBag)

    didTapCellSubject.asObserver().subscribe(onNext: { [weak self] (indexPath) in
      guard let section = self?.sectionsRelay.value[safe: indexPath.section]?.items[safe: indexPath.row] else {
        return
      }
      if
        section.identifier == "TitleCellAchievements_ShowAll" ||
        section.identifier == "TitleCellAchievements_HideAll" {
        self?.shouldShowAllAchievements = !(self?.shouldShowAllAchievements ?? false)
        self?.createSections()
      }
      if
        section.identifier == "TitleCellStats_ShowAll" ||
        section.identifier == "TitleCellStats_HideAll" {
        self?.shouldShowAllStats = !(self?.shouldShowAllStats ?? false)
        self?.createSections()
      }
    }).disposed(by: disposeBag)
  }

  func getAchievements() {
    Observable.zip(
      self.dependencies.gameManager.gameStats(id: gameId),
      self.dependencies.userManager.gameStats(userId: userId, gameId: gameId)
    ).do(onNext: { [weak self] (res) in
      let gameSchema = res.0
      let gameStats = res.1

      var schemaStat = [String: GameStat]()
      gameSchema.0.forEach { (schema) in
        schemaStat[schema.name ?? ""] = schema
      }

      var schemaAchievements = [String: GameAchievement]()
      gameSchema.1.forEach { (schema) in
        schemaAchievements[schema.name ?? ""] = schema
      }

      self?.achievments = gameStats.1.map({ (achievement) -> GameAchievement in
        let newAchievements = achievement
        if let schema = schemaAchievements[achievement.name ?? ""] {
          newAchievements.desc = schema.desc
          newAchievements.displayName = schema.displayName
          newAchievements.iconURL = schema.iconURL
          newAchievements.icongrayURL = schema.icongrayURL
          newAchievements.hidden = schema.hidden
          return newAchievements
        }
        return achievement
      })

      self?.userStats = gameStats.0.map({ (stat) -> GameStat in
        let newStat = stat
        if let stat = schemaStat[stat.name ?? ""] {
          newStat.displayName = stat.displayName
          return newStat
        }
        return stat
      })
    }, afterNext: { [weak self] (res) in
      self?.createSections()
    }, onError: { (error) in
      //show error
    }).subscribe().disposed(by: disposeBag)
  }

  func getGameInfo() {
    self.dependencies.gameManager.game(id: gameId).do(onNext: { [weak self] (game) in
      self?.game = game
      self?.createSections()
    }, afterNext: { [weak self] (game) in
      self?.createSections()
      self?.titleSubject.onNext(game?.name)
      if let screens = game?.screenshots{
        let sources = screens.map({ (screen) -> URL? in
          return screen.fullURL
        }).filter({ (url) -> Bool in
          return url != nil
        }).map { (url) -> InputSource? in
          if let url = url {
            return AlamofireSource(url: url)
          }
          return nil
        }.filter { $0 != nil } as? [InputSource]
        self?.imagesSubject.onNext(sources ?? [])
      }
    }, onError: { (error) in
      //Show error
    }, onCompleted: { [weak self] in
      self?.isLoadingSubject.onNext(false)
    }, onSubscribe: { [weak self] in
      self?.isLoadingSubject.onNext(true)
    }).subscribe().disposed(by: disposeBag)
  }

  // MARK: -

  func createSections() {
    var sctns = [BaseTableSectionItem]()
    var cells = [BaseCellItem]()

    if isFavoriteGame {
      let chartCell = ChartCellItem(reuseIdentifier: "ChartCell",
                                    identifier: "ChartCell")
      chartCell.data = chartData()

      var chartSection = BaseTableSectionItem(header: " ", items: [chartCell])
      chartSection.identifier = "ChartSection"
      sctns.append(chartSection)
    }

    if achievments.count > 0 || userStats.count > 0 {
      let gameStatCell = TwoTileCellItem(reuseIdentifier: "TwoTileCell",
                                         identifier: "TwoTileCell")
      if achievments.count > 0 {
        gameStatCell.firstTileKey = "Achievements"
        gameStatCell.firstTileValue = "\(achievments.count)"
      }

      if userStats.count > 0 && achievments.count > 0 {
        gameStatCell.secondTileKey = "Stats"
        gameStatCell.secondTileValue = "\(userStats.count)"
      } else if achievments.count == 0 {
        gameStatCell.firstTileKey = "Stats"
        gameStatCell.firstTileValue = "\(userStats.count)"
      }

      var achievementsCells = [BaseCellItem]()
      achievementsCells.append(gameStatCell)

      var achievementsSection = BaseTableSectionItem(header: " ", items: achievementsCells)
      achievementsSection.identifier = "AchievementsShowcaseSection"
      if achievementsCells.count > 0 {
        sctns.append(achievementsSection)
      }
    }

    // Building Achievement Section
    if achievments.count > 0 {
      var achievementsCells = [BaseCellItem]()
      let achCells = (achievments[safe: 0..<(shouldShowAllAchievements ? achievments.count : achievementsOnPage)] ?? [])
        .map { (achie) -> BaseCellItem in
          let achCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                      identifier: "TitleCellAchievements_\(achie.name ?? String.random())")
          achCell.title = achie.displayName ?? achie.name
          return achCell
      }
      achievementsCells.append(contentsOf: achCells)

      if achievments.count > achievementsOnPage {
        if shouldShowAllAchievements {
          let achCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                      identifier: "TitleCellAchievements_ShowAll")
          achCell.title = "Hide Achievements"
          achievementsCells.append(achCell)
        } else {
          let achCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                      identifier: "TitleCellAchievements_HideAll")
          achCell.title = "See All Achievements"
          achievementsCells.append(achCell)
        }
      }
      var achievementsSection = BaseTableSectionItem(header: "Achievements",
                                                     items: achievementsCells)
      achievementsSection.identifier = "AchievementsSection"
      if achievementsCells.count > 0 {
        sctns.append(achievementsSection)
      }
    }

    // Building Stats Section
    if userStats.count > 0 {
      var userStatsCells = [BaseCellItem]()
      let statCells = (userStats[safe: 0..<(shouldShowAllStats ? userStats.count : statsOnPage)] ?? [])
        .map { (stat) -> BaseCellItem in
          let statCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                       identifier: "TitleCellStats_\(stat.name ?? "")")
          let leftPart = stat.displayName ?? stat.name ?? ""
          let rightPart: String = stat.value != nil ? String(stat.value ?? 0) : ""

          statCell.title = "\(leftPart): \(rightPart)"
          return statCell
      }
      userStatsCells.append(contentsOf: statCells)

      if userStats.count > statsOnPage {
        if shouldShowAllStats {
          let userStatsCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                            identifier: "TitleCellStats_HideAll")
          userStatsCell.title = "Hide Stats"
          userStatsCells.append(userStatsCell)
        } else {
          let userStatsCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                            identifier: "TitleCellStats_ShowAll")
          userStatsCell.title = "See All Stats"
          userStatsCells.append(userStatsCell)
        }
      }

      var statsSection = BaseTableSectionItem(header: "Stats", items: userStatsCells)
      statsSection.identifier = "StatsSection"
      if userStatsCells.count > 0 {
        sctns.append(statsSection)
      }
    }

    // Building Game Info Section
    if self.game != nil {
      let priceCell = TextCellItem(reuseIdentifier: "TextCell",
                                   identifier: "GameInfoCell_Price")
      priceCell.text = (self.game?.isFree ?? false) ? "Free" : self.game?.price?.htmlStripped
      cells.append(priceCell)

      let aboutCell = TextCellItem(reuseIdentifier: "TextCell",
                                       identifier: "GameInfoCell_About")
      aboutCell.text = self.game?.aboutDesc?.htmlStripped
      cells.append(aboutCell)

      let descCell = TextCellItem(reuseIdentifier: "TextCell",
                                      identifier: "GameInfoCell_Desc")
      descCell.text = self.game?.detailedDesc?.htmlStripped
      cells.append(descCell)

      var section = BaseTableSectionItem(header: " ", items: cells)
      section.identifier = "BaseTableSection_1"
      sctns.append(section)
    }
    sectionsRelay.accept(sctns)
  }

  // MARK: -

  func chartData() -> [Date: [String: (String, UIColor, Int)]] {
    var preparedData: [Date: [String: (String, UIColor, Int)]] = [:]
    for (date, value) in self.dependencies.statisticProvider?.statistics(for: userId) ?? [:] {
      for (color, (name, vv)) in zip([UIColor.red, UIColor.blue], value) {
        if preparedData[date] == nil {
          preparedData[date] = [:]
        }
        preparedData[date]?[name] = (vv.0 ?? name, color, vv.1)
      }
    }
    return preparedData
  }
}
