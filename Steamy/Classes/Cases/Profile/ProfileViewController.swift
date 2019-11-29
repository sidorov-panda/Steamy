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

class ProfileViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = ProfileViewModel

  func configure(with viewModel: ProfileViewModel) {
    self.viewModel = viewModel
  }

  var viewModel: ProfileViewModel!

  // MARK: -

  var tableView = UITableView()

  // MARK: -

  var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .defaultBackgroundColor
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

  func configureUI() {
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
    tableView.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
    tableView.register(FavoriteGameCell.self, forCellReuseIdentifier: "FavoriteGameCell")
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

extension ProfileViewController: IndicatorInfoProvider {
  public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Profile")
  }
}
