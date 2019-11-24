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

class ProfileViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = ProfileViewModel

  func configure(with viewModel: ProfileViewModel) {
    self.viewModel = viewModel
  }

  var viewModel: ProfileViewModel!

  // MARK: -

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .defaultBackgroundColor
  }
}

extension ProfileViewController: IndicatorInfoProvider {
  public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Profile")
  }
}
