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

class ActivityViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = ActivityViewModel

  func configure(with viewModel: ActivityViewModel) {
    self.viewModel = viewModel
  }

  var viewModel: ActivityViewModel!

  // MARK: -

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension ActivityViewController: IndicatorInfoProvider {
  public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Activity")
  }
}
