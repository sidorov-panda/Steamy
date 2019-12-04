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
  }

  struct Output {
    var backgroundImage: Observable<URL?>
    var headerImage: Observable<URL?>
    var title: Observable<String?>
    var isLoading: Observable<Bool>
    var sections: Observable<[BaseTableSectionItem]>
    var images: Observable<[InputSource]>
  }

  var input: GameViewModel.Input!
  var output: GameViewModel.Output!

  // MARK: -

  private var backgroundImageSubject = PublishSubject<URL?>()
  private var headerImageSubject = PublishSubject<URL?>()
  private var titleSubject = PublishSubject<String?>()
  private var isLoadingSubject = PublishSubject<Bool>()
  private var viewDidLoadSubject = PublishSubject<Void>()
  private var imagesSubject = PublishSubject<[InputSource]>()
  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])

  // MARK: -
  
  var achievementsOnPage = 3
  var statsOnPage = 3

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

    self.input = Input(viewDidLoad: viewDidLoadSubject.asObserver())
    self.output = Output(backgroundImage: backgroundImageSubject.asObservable(),
                         headerImage: headerImageSubject.asObservable(),
                         title: titleSubject.asObservable(),
                         isLoading: isLoadingSubject.asObservable(),
                         sections: sectionsRelay.asObservable(),
                         images: imagesSubject.asObservable())

    viewDidLoadSubject.subscribe(onNext: { [weak self] (_) in
      self?.isLoadingSubject.onNext(true)
      self?.getGameInfo()
      self?.getAchievements()
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
      if let backgroundImage = game?.backgroundImageURL {
        self?.backgroundImageSubject.onNext(backgroundImage)
      }
    }, onError: { (error) in
      //Show error
    }, onCompleted: { [weak self] in
      self?.isLoadingSubject.onNext(false)
    }, onSubscribe: { [weak self] in
      self?.isLoadingSubject.onNext(true)
    }).subscribe().disposed(by: disposeBag)
  }

  func createSections() {
    var sctns = [BaseTableSectionItem]()
    var cells = [BaseCellItem]()

    if isFavoriteGame {
      let chartCell = ChartCellItem(reuseIdentifier: "ChartCell", identifier: "ChartCell")

//      var preparedData: [Date: [String: (String, UIColor, Int)]] = [:]
//      for (key, value) in self.dependencies.statisticProvider?.statistics(for: userId) ?? [:] {
//        for (kk, vv) in value {
//          if preparedData[key] == nil {
//            preparedData[key] = [:]
//          }
//          preparedData[key]?[kk] = (vv.0 ?? kk, UIColor.red, vv.1)
//        }
//      }

      chartCell.data = chartData()
      var chartSection = BaseTableSectionItem(header: " ", items: [chartCell])
      chartSection.identifier = "ChartSection"
      sctns.append(chartSection)
    }

    // Building Achievement Section
    if self.achievments.count > 0 {
      var achievementsCells = [BaseCellItem]()
      let achCells = (self.achievments[safe: 0..<achievementsOnPage] ?? []).map { (achie) -> BaseCellItem in
        let achCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                    identifier: "TitleCellAchievements_\(achie.name ?? String.random())")
        achCell.title = achie.displayName ?? achie.name
        return achCell
      }
      achievementsCells.append(contentsOf: achCells)

      if self.achievments.count > achievementsOnPage {
        let achCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                    identifier: "TitleCellAchievements_SeeAll")
        achCell.title = "See All Achievements"
        achievementsCells.append(achCell)
      }
      var achievementsSection = BaseTableSectionItem(header: "You have \(self.achievments.count) achievements", items: achievementsCells)
      achievementsSection.identifier = "AchievementsSection"
      if achievementsCells.count > 0 {
        sctns.append(achievementsSection)
      }
    }

    // Building Stats Section
    if userStats.count > 0 {
      var userStatsCells = [BaseCellItem]()
      let statCells = (self.userStats[safe: 0..<statsOnPage] ?? []).map { (stat) -> BaseCellItem in
        let statCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                     identifier: "TitleCellStats_\(stat.name ?? "")")
        let leftPart = stat.displayName ?? stat.name ?? ""
        let rightPart: String = stat.value != nil ? String(stat.value ?? 0) : ""

        statCell.title = "\(leftPart): \(rightPart)"
        return statCell
      }
      userStatsCells.append(contentsOf: statCells)

      if self.userStats.count > statsOnPage {
        let userStatsCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                          identifier: "TitleCellStats_SeeAll")
        userStatsCell.title = "See All Stats"
        userStatsCells.append(userStatsCell)
      }
      var statsSection = BaseTableSectionItem(header: "Stats", items: userStatsCells)
      statsSection.identifier = "StatsSection"
      if userStatsCells.count > 0 {
        sctns.append(statsSection)
      }
    }

    // Building Game Info Section
    let priceCell = GameInfoCellItem(reuseIdentifier: "GameInfoCell",
                                     identifier: "GameInfoCell_Price")
    priceCell.attributedText = NSAttributedString(html: self.game?.price ?? "")
    cells.append(priceCell)

    let descCell = GameInfoCellItem(reuseIdentifier: "GameInfoCell",
                                    identifier: "GameInfoCell_Desc")
    descCell.attributedText = NSAttributedString(html: self.game?.detailedDesc ?? "")
    cells.append(descCell)

    let aboutCell = GameInfoCellItem(reuseIdentifier: "GameInfoCell",
                                     identifier: "GameInfoCell_About")
    aboutCell.attributedText = NSAttributedString(html: self.game?.aboutDesc ?? "")
    cells.append(aboutCell)

    var section = BaseTableSectionItem(header: " ", items: cells)
    section.identifier = "BaseTableSection_1"
    sctns.append(section)
    sectionsRelay.accept(sctns)
  }

  // MARK: -

  func chartData() -> [Date: [String: (String, UIColor, Int)]] {
    var preparedData: [Date: [String: (String, UIColor, Int)]] = [:]
    for (date, value) in self.dependencies.statisticProvider?.statistics(for: userId) ?? [:] {
      for (name, vv) in value {
        if preparedData[date] == nil {
          preparedData[date] = [:]
        }
        preparedData[date]?[name] = (vv.0 ?? name, .red, vv.1)
      }
    }
    return preparedData
  }

}
