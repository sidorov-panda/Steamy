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

struct GameViewModelDependency {
  var userManager: UserManager
  var gameManager: GameManager
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
  }

  var input: GameViewModel.Input!
  var output: GameViewModel.Output!

  // MARK: -

  private var backgroundImageSubject = PublishSubject<URL?>()
  private var headerImageSubject = PublishSubject<URL?>()
  private var titleSubject = PublishSubject<String?>()
  private var isLoadingSubject = PublishSubject<Bool>()
  private var viewDidLoadSubject = PublishSubject<Void>()
  private var sectionsRelay = BehaviorRelay<[BaseTableSectionItem]>(value: [])

  // MARK: -

  var dependencies: GameViewModelDependency
  var gameId: Int
  var userId: Int
  var game: Game? {
    didSet {
      createSections()
      self.isLoadingSubject.onNext(false)
      self.titleSubject.onNext(game?.name)
      if let backgroundImage = game?.backgroundImageURL {
        self.backgroundImageSubject.onNext(backgroundImage)
      }
    }
  }

  var achievments: [UserAchievement] = []

  init?(userId: Int, gameId: Int, dependencies: GameViewModelDependency) {
    self.userId = userId
    self.gameId = gameId
    self.dependencies = dependencies

    super.init()

    self.input = Input(viewDidLoad: viewDidLoadSubject.asObserver())
    self.output = Output(backgroundImage: backgroundImageSubject.asObservable(),
                         headerImage: headerImageSubject.asObservable(),
                         title: titleSubject.asObservable(),
                         isLoading: isLoadingSubject.asObservable(),
                         sections: sectionsRelay.asObservable())

    viewDidLoadSubject.subscribe(onNext: { [weak self] (_) in
      self?.isLoadingSubject.onNext(true)

      dependencies.gameManager.game(id: gameId) { [weak self] (game, error) in
        self?.game = game
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self?.getAchievements()
      }
    }).disposed(by: disposeBag)
  }

  func getAchievements() {
    self.dependencies.userManager.achievements(userId: self.userId, gameId: gameId) { (achievements, error) in
      self.achievments = achievements ?? []
      self.createSections()
    }
  }

  func createSections() {
    var sctns = [BaseTableSectionItem]()
    var cells = [BaseCellItem]()

    if self.achievments.count > 0 {
      let achieved = self.achievments.filter { (ach) -> Bool in
        return ach.achieved
      }.count
      let achCell = GameInfoCellItem(reuseIdentifier: "GameInfoCell", identifier: "GameInfoCell_Achievements")
      achCell.attributedText = NSAttributedString(html: "\(achieved) of \(self.achievments.count) achieved")
      cells.append(achCell)
    }

    let priceCell = GameInfoCellItem(reuseIdentifier: "GameInfoCell", identifier: "GameInfoCell_Price")
    priceCell.attributedText = NSAttributedString(html: self.game?.price ?? "")
    cells.append(priceCell)

    let descCell = GameInfoCellItem(reuseIdentifier: "GameInfoCell", identifier: "GameInfoCell_Desc")
    descCell.attributedText = NSAttributedString(html: self.game?.detailedDesc ?? "")
    cells.append(descCell)

    let aboutCell = GameInfoCellItem(reuseIdentifier: "GameInfoCell", identifier: "GameInfoCell_About")
    aboutCell.attributedText = NSAttributedString(html: self.game?.aboutDesc ?? "")
    cells.append(aboutCell)

    var section = BaseTableSectionItem(header: " ", items: cells)
    section.identifier = "BaseTableSection_1"
    sectionsRelay.accept([section])
  }

}
