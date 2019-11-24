//
//  UserViewController.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources
import XLPagerTabStrip

class UserViewController: ButtonBarPagerTabStripViewController, ControllerProtocol {

  var disposeBag = DisposeBag()

  // MARK: - ViewModel

  var viewModel: UserViewModel!

  typealias ViewModelType = UserViewModel

  func configure(with viewModel: UserViewModel) {
    self.viewModel = viewModel
  }

  func bind() {
    userInfoView.configure(item: viewModel.output.userInfoItem())

//    viewModel
//      .output
//      .sections
//      .bind(to: tableView.rx.items(dataSource: rxDataSource!))
//      .disposed(by: disposeBag)

  }

  // MARK: -

  var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

  override func viewDidLoad() {
    self.containerView = self.scrollView
    self.delegate = self
    self.datasource = self

    settings.style.buttonBarMinimumInteritemSpacing = 1
    settings.style.buttonBarMinimumLineSpacing = 1
    settings.style.buttonBarLeftContentInset = 32
    settings.style.selectedBarBackgroundColor = .white
    settings.style.selectedBarHeight = 1
    settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 12.0)
    settings.style.buttonBarHeight = 31
    settings.style.buttonBarBackgroundColor = .defaultBackgroundColor
    settings.style.buttonBarItemBackgroundColor = .white
    settings.style.buttonBarItemTitleColor = .white
    settings.style.buttonBarItemBackgroundColor = .defaultBackgroundColor
    settings.style.buttonBarItemsShouldFillAvailableWidth = false
    settings.style.selectedBarHeight = 2
    
    super.viewDidLoad()

    configureUI()

//    rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>(
//      configureCell: { [weak self] dataSource, tableView, indexPath, sm in
//
//        guard
//          let item = try? dataSource.model(at: indexPath) as? BaseCellItem,
//          let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? ConfigurableCell else {
//            return UITableViewCell()
//        }
//        cell.configure(item: item)
//        return cell
//    })

//    rxDataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
//                                                                  reloadAnimation: .automatic,
//                                                                  deleteAnimation: .automatic)
    bind()
//    tableView.rx.setDelegate(self).disposed(by: disposeBag)
  }

  // MARK: -

  var scrollView: UIScrollView = UIScrollView()

  let userInfoView = UserInfoView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

  func configureUI() {
    self.view.backgroundColor = .defaultBackgroundColor

    buttonBarView.selectedBar.layer.cornerRadius = 2.0

    self.view.addSubview(userInfoView)
    self.view.addSubview(scrollView)

    userInfoView.snp.makeConstraints { (maker) in
      maker.top.equalTo(self.view).offset(50)
      maker.leading.equalTo(self.view)
      maker.trailing.equalTo(self.view)
      maker.height.equalTo(83)
    }

    buttonBarView.snp.makeConstraints { (maker) in
      maker.top.equalTo(userInfoView.snp.bottom).offset(32)
      maker.leading.equalTo(self.view)
      maker.trailing.equalTo(self.view)
      maker.height.equalTo(31)
    }

    scrollView.snp.makeConstraints { (maker) in
      maker.top.equalTo(buttonBarView.snp.bottom)
      maker.bottom.equalTo(self.view)
      maker.leading.equalTo(self.view)
      maker.trailing.equalTo(self.view)
    }
  }

  override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    return [ProfileViewController(), ActivityViewController(), FriendsViewController(), ProfileViewController(), ProfileViewController()]
  }
}
