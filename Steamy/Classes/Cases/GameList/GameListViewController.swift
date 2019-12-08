//
//  ProfileViewController.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import XLPagerTabStrip
import RxDataSources
import SnapKit

class GameListViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = GameListViewModel

  func configure(with viewModel: GameListViewModel) {
    self.viewModel = viewModel
  }

  var viewModel: GameListViewModel!

  // MARK: -

  let tableView = UITableView()
  let searchBar = UISearchBar()

  // MARK: -

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
    })

    rxDataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                  reloadAnimation: .automatic,
                                                                  deleteAnimation: .automatic)

    bind()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.title = "Games"
    self.navigationController?.navigationBar.isTranslucent = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isTranslucent = true
  }

  func configureUI() {
    tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

    view.backgroundColor = .defaultBackgroundColor
    tableView.backgroundColor = .defaultBackgroundCellColor
    tableView.separatorStyle = .none
    self.view.addSubview(tableView)

    tableView.snp.makeConstraints({ (maker) in
      maker.leading.equalTo(self.view)
      maker.top.equalTo(self.view)
      maker.right.equalTo(self.view)
      maker.bottom.equalTo(self.view)
    })
    searchBar.searchBarStyle = UISearchBar.Style.prominent
    searchBar.placeholder = "Search game"
    searchBar.sizeToFit()
    searchBar.isTranslucent = true
    searchBar.backgroundImage = UIImage()
    searchBar.backgroundColor = .defaultBackgroundCellColor
    searchBar.tintColor = .white
    searchBar.searchTextField.textColor = .white
    navigationItem.titleView = searchBar
  }

  func registerCells() {
    tableView.register(GameCell.self, forCellReuseIdentifier: "GameCell")
    tableView.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
    tableView.register(LoadingCell.self, forCellReuseIdentifier: "LoadingCell")
  }

  func bind() {
    //Output
    viewModel
      .output
      .sections
      .bind(to: tableView.rx.items(dataSource: rxDataSource!))
      .disposed(by: disposeBag)

    viewModel
      .output
      .showController
      .subscribe(onNext: { [weak self] (viewController) in
        self?.navigationController?.pushViewController(viewController, animated: true)
      }).disposed(by: disposeBag)

    //Input
    tableView
      .rx
      .itemSelected
      .asDriver()
      .drive(viewModel.input.didTapCell)
      .disposed(by: disposeBag)

    searchBar
      .rx
      .text
      .asDriver()
      .drive(viewModel.input.searchTerm)
      .disposed(by: disposeBag)
  }
}

extension GameListViewController: IndicatorInfoProvider {
  public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Profile")
  }
}
