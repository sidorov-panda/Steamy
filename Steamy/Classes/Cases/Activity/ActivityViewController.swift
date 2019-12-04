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
import RealmSwift
import Charts
import SnapKit
import RxDataSources

class ActivityViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = ActivityViewModel

  func configure(with viewModel: ActivityViewModel) {
    self.viewModel = viewModel
  }

  var viewModel: ActivityViewModel!

  // MARK: -

  var tableView = UITableView(frame: .zero, style: .grouped)

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
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  func configureUI() {
    view.backgroundColor = .defaultBackgroundCellColor
    tableView.backgroundColor = .defaultBackgroundCellColor
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .none

    if #available(iOS 11.0, *) {
      tableView.contentInset = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
    }
    self.view.addSubview(tableView)

    tableView.snp.makeConstraints({ (maker) in
      maker.leading.equalTo(self.view)
      maker.top.equalTo(self.view)
      maker.right.equalTo(self.view)
      maker.bottom.equalTo(self.view)
    })
  }

  func registerCells() {
    tableView.register(GameCell.self, forCellReuseIdentifier: "GameCell")
    tableView.register(ActivityCell.self, forCellReuseIdentifier: "ActivityCell")
    tableView.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
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
  }
}

extension ActivityViewController: IndicatorInfoProvider {
  public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Activity")
  }
}
