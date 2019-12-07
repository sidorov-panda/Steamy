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

  // MARK: -

  override func viewDidLoad() {
    self.containerView = self.scrollView
    self.delegate = self
    self.datasource = self

    settings.style.buttonBarMinimumInteritemSpacing = 1
    settings.style.buttonBarMinimumLineSpacing = 1
    settings.style.buttonBarLeftContentInset = 10
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

    if #available(iOS 11.0, *) {} else {
      automaticallyAdjustsScrollViewInsets = false
    }

    configureUI()
    bind()
  }

  // MARK: -

  var scrollView = UIScrollView()

  let userInfoView = UserInfoView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

  func configureUI() {
    view.backgroundColor = .defaultBackgroundColor
    buttonBarView.selectedBar.layer.cornerRadius = 2.0

    self.view.addSubview(userInfoView)
    self.view.addSubview(scrollView)

    userInfoView.snp.makeConstraints { (maker) in
      maker.top.equalTo(self.view).offset(100)
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

  func bind() {
    userInfoView.configure(item: viewModel.output.userInfoItem())
  }

  override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    return viewModel.output.userPages()
  }
}
