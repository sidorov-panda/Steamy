//
//  GameViewController.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlamofireImage
import SVProgressHUD
import RxDataSources
import ImageSlideshow
import SafariServices

class GameViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = GameViewModel

  var viewModel: GameViewModel!

  func configure(with viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  // MARK: -

  func bind() {
    //Output
    viewModel
      .output
      .sections
      .retry()
      .bind(to: tableView.rx.items(dataSource: rxDataSource!))
      .disposed(by: disposeBag)

    viewModel
      .output
      .title
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (title) in
        self?.title = title
      }).disposed(by: disposeBag)

    viewModel
      .output
      .isLoading
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { (val) in
        if val {
          SVProgressHUD.show()
        } else {
          SVProgressHUD.dismiss()
        }
      }).disposed(by: disposeBag)

    viewModel
      .output
      .images
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] (images) in
        if images.count > 0 {
          self?.slideshow.setImageInputs(images)
          self?.slideshow.contentScaleMode = .scaleAspectFill
          self?.tableView.tableHeaderView = self?.slideshow
        } else {
          self?.tableView.tableHeaderView = nil
        }
      }).disposed(by: disposeBag)

    viewModel.output.openURL.asDriver(onErrorJustReturn: nil).drive(onNext: { (url) in
      if let url = url {
        let viewController = SFSafariViewController(url: url)
        self.present(viewController, animated: true, completion: nil)
      }
    }).disposed(by: disposeBag)

    //Input
    tableView
      .rx
      .itemSelected
      .asDriver()
      .drive(viewModel.input.didTapCell)
      .disposed(by: disposeBag)

    viewModel.input.viewDidLoad.onNext(())
  }

  // MARK: -

  var tableView = UITableView(frame: .zero, style: .grouped)

  var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

  override func viewDidLoad() {
    super.viewDidLoad()

    configureUI()
    registerCells()

    rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>(
      configureCell: { dataSource, tableView, indexPath, sm in
        guard
          let item = try? dataSource.model(at: indexPath) as? BaseCellItem,
          let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? ConfigurableCell else {
            return UITableViewCell()
        }
        cell.configure(item: item)
        return cell
      }, titleForHeaderInSection: { source, index in
        guard let sectionModel = source.sectionModels[safe: index] else {
          return nil
        }
        return sectionModel.header
      })

    rxDataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                  reloadAnimation: .automatic,
                                                                  deleteAnimation: .automatic)
    bind()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isTranslucent = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isTranslucent = true
  }

  func registerCells() {
    tableView.register(GameInfoCell.self, forCellReuseIdentifier: "GameInfoCell")
    tableView.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
    tableView.register(ChartCell.self, forCellReuseIdentifier: "ChartCell")
    tableView.register(TwoTileCell.self, forCellReuseIdentifier: "TwoTileCell")
    tableView.register(TextCell.self, forCellReuseIdentifier: "TextCell")
    tableView.register(KeyValueCell.self, forCellReuseIdentifier: "KeyValueCell")
    tableView.register(ArticleCell.self, forCellReuseIdentifier: "ArticleCell")
    tableView.register(AchievementCell.self, forCellReuseIdentifier: "AchievementCell")
    tableView.register(LoadingCell.self, forCellReuseIdentifier: "LoadingCell")
  }

  // MARK: -

  var slideshow = ImageSlideshow(frame: CGRect(x: 0, y: 0, width: 10, height: 140))

  func configureUI() {
    view.addSubview(tableView)
    view.backgroundColor = .defaultBackgroundCellColor
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = .defaultBackgroundCellColor
    tableView.estimatedRowHeight = 55
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none

    tableView.snp.makeConstraints { (maker) in
      maker.top.equalTo(self.view)
      maker.left.equalTo(self.view)
      maker.right.equalTo(self.view)
      maker.bottom.equalTo(self.view)
    }
  }
}
