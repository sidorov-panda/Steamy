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
    var openURL: Observable<URL?>
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
  private var openURLSubject = PublishSubject<URL?>()

  // MARK: -

  var achievementsOnPage = 3
  var statsOnPage = 3
  var articlesOnPage = 3

  var shouldShowAllAchievements = false
  var shouldShowAllStats = false
  var shouldShowAllNews = false

  var dependencies: GameViewModelDependency
  var gameId: Int
  var userId: Int
  var game: Game?
  var isFavoriteGame: Bool
  var timePlayed: Int?

  var achievments: [GameAchievement] = []
  var userStats: [GameStat] = []
  var articles: [Article] = []

  init?(userId: Int, gameId: Int, timePlayed: Int? = nil, isFavoriteGame: Bool = false, dependencies: GameViewModelDependency) {
    self.userId = userId
    self.gameId = gameId
    self.timePlayed = timePlayed
    self.isFavoriteGame = isFavoriteGame
    self.dependencies = dependencies

    super.init()

    self.input = Input(viewDidLoad: viewDidLoadSubject.asObserver(),
                       didTapCell: didTapCellSubject.asObserver())
    self.output = Output(headerImage: headerImageSubject.asObservable(),
                         title: titleSubject.asObservable(),
                         isLoading: isLoadingSubject.asObservable(),
                         sections: sectionsRelay.asObservable(),
                         images: imagesSubject.asObservable(),
                         openURL: openURLSubject.asObservable())

    bind()
  }

  // MARK: -

  func bind() {
    viewDidLoadSubject.subscribe(onNext: { [weak self] (_) in
      self?.isLoadingSubject.onNext(true)
      self?.getGameInfo()
      self?.getAchievements()
      self?.getNews()
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
      if
        section.identifier == "TitleCellArticle_ShowAll" ||
        section.identifier == "TitleCellArticle_HideAll" {
        self?.shouldShowAllNews = !(self?.shouldShowAllNews ?? false)
        self?.createSections()
      }

      if section.identifier.starts(with: "ArticleCell") {
        guard let articleId = section.identifier.split(separator: "_").last else {
          return
        }
        let hasURL = self?.articles.filter({ (article) -> Bool in
          return article.id == String(articleId)
        }).first
        if let url = hasURL?.url {
          self?.openURLSubject.onNext(url)
        }
      }
    }).disposed(by: disposeBag)
  }

  func getNews() {
    self.dependencies.gameManager.news(gameId: gameId) { [weak self] (articles, error) in
      self?.articles = (articles ?? []).map({ (article) -> Article in
        let newArticle = article
        newArticle.contents = article.contents?.htmlStripped
        return newArticle
      })
      self?.createSections()
    }
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
      }).filter({ (stat) -> Bool in
        return stat.displayName != nil
          && stat.displayName != ""
          && stat.name != nil
          && stat.name != ""
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

  //TODO: разнести создание секций по разным методам
  func createSections() {
    var sctns = [BaseTableSectionItem]()

    let charts = chartData()
    if isFavoriteGame && charts.keys.count > 0 {
      let chartCell = ChartCellItem(reuseIdentifier: "ChartCell",
                                    identifier: "ChartCell")
      chartCell.data = charts

      var chartSection = BaseTableSectionItem(header: " ", items: [chartCell])
      chartSection.identifier = "ChartSection"
      sctns.append(chartSection)
    }

    if achievments.count > 0 || timePlayed != nil {
      let gameStatCell = TwoTileCellItem(reuseIdentifier: "TwoTileCell",
                                         identifier: "TwoTileCell_\(achievments.count)_\(timePlayed ?? 0)")
      if achievments.count > 0 {
        gameStatCell.firstTileKey = "Achievements"
        gameStatCell.firstTileValue = "\(achievments.count)"
      }

      let playedTimeComponents = ((timePlayed ?? 0) * 60).secondsToHoursMinutesSeconds()
      var timePlayedStr = ""
      if (playedTimeComponents.0) > 0 {
        timePlayedStr += "\(playedTimeComponents.0) h"
      } else
        //showing mins only if there's no hours
      if (playedTimeComponents.1) > 0 {
        timePlayedStr += "\(playedTimeComponents.1) min"
      }
      if timePlayedStr != "" && achievments.count > 0 {
        gameStatCell.secondTileKey = "Time Played"
        gameStatCell.secondTileValue = timePlayedStr
      } else if achievments.count == 0 {
        gameStatCell.firstTileKey = "Time Played"
        gameStatCell.firstTileValue = timePlayedStr
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
      achievementsCells.append(contentsOf: achievementCells())

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
      userStatsCells.append(contentsOf: statCells())

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

    var cells = [BaseCellItem]()
    // Building Game Info Section
    if let game = self.game {
      cells.append(priceCellItem(game: game))
      cells.append(aboutCellItem(game: game))
      cells.append(descCellItem(game: game))
      var section = BaseTableSectionItem(header: " ", items: cells)
      section.identifier = "BaseTableSection_1"
      sctns.append(section)
    }

    if articles.count > 0 {
      sctns.append(newsSection())
    }

    sectionsRelay.accept(sctns)
  }

  // MARK: - CellItems

  func newsSection() -> BaseTableSectionItem {
    var section = BaseTableSectionItem(header: "NEWS", items: articlesCellItems())
    section.identifier = "NewsSection"
    return section
  }

  private let articleDateFormatter = DateFormatter(withFormat: "MMM dd yyyy", locale: NSLocale.current.identifier)
  func articlesCellItems() -> [BaseCellItem] {
    var cells = (articles[safe: 0..<(shouldShowAllNews ? articles.count : articlesOnPage)] ?? [])
      .map { (article) -> BaseCellItem in
        let cell = ArticleCellItem(reuseIdentifier: "ArticleCell",
                                   identifier: "ArticleCell_\(article.id ?? String.random())")
        cell.author = article.author
        cell.content = article.contents
        cell.title = article.title
        cell.date = self.articleDateFormatter.string(from: article.date ?? Date())
        return cell
    }

    if articles.count > articlesOnPage {
      if shouldShowAllNews {
        let articlesCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                         identifier: "TitleCellArticle_HideAll")
        articlesCell.title = "Hide News"
        cells.append(articlesCell)
      } else {
        let articlesCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                         identifier: "TitleCellArticle_ShowAll")
        articlesCell.title = "See All News"
        cells.append(articlesCell)
      }
    }
    return cells
  }

  func statCells() -> [BaseCellItem] {
    return (userStats[safe: 0..<(shouldShowAllStats ? userStats.count : statsOnPage)] ?? [])
      .map { (stat) -> BaseCellItem in
        let statCell = KeyValueCellItem(reuseIdentifier: "KeyValueCell",
                                        identifier: "KeyValueCell_\(stat.name ?? "")")
        let leftPart = stat.displayName ?? stat.name ?? ""
        let rightPart: String = stat.value != nil ? String(stat.value ?? 0) : ""
        statCell.key = leftPart
        statCell.value = rightPart
        return statCell
    }
  }

  func achievementCells() -> [BaseCellItem] {
    return (achievments[safe: 0..<(shouldShowAllAchievements ? achievments.count : achievementsOnPage)] ?? [])
      .map { (achie) -> BaseCellItem in
        let achCell = TitleCellItem(reuseIdentifier: "TitleCell",
                                    identifier: "TitleCellAchievements_\(achie.name ?? String.random())")
        achCell.title = achie.displayName ?? achie.name
        return achCell
    }
  }

  func priceCellItem(game: Game) -> BaseCellItem {
    let priceCell = TextCellItem(reuseIdentifier: "TextCell",
                                 identifier: "GameInfoCell_Price")
    priceCell.text = game.isFree ? "Free" : game.price?.htmlStripped
    return priceCell
  }

  func aboutCellItem(game: Game) -> BaseCellItem {
    let aboutCell = TextCellItem(reuseIdentifier: "TextCell",
                                     identifier: "GameInfoCell_About")
    aboutCell.text = game.aboutDesc?.htmlStripped
    return aboutCell
  }

  func descCellItem(game: Game) -> BaseCellItem {
    let descCell = TextCellItem(reuseIdentifier: "TextCell",
                                    identifier: "GameInfoCell_Desc")
    descCell.text = game.detailedDesc?.htmlStripped
    return descCell
  }

  // MARK: -

  typealias ChartData = [Date: [String: (String, UIColor, Int)]]

  func chartData() -> ChartData {
    var preparedData: ChartData = [:]
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
