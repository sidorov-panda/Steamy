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

class FriendsViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = FriendsViewModel

  func configure(with viewModel: FriendsViewModel) {
    self.viewModel = viewModel
  }

  var viewModel: FriendsViewModel!

  // MARK: -

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension FriendsViewController: IndicatorInfoProvider {
  public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Friends")
  }
}
