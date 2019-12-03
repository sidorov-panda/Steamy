//
//  BaseViewController.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import RxSwift

protocol ControllerProtocol: class {

  var viewModel: ViewModelType! { get set }

  associatedtype ViewModelType: ViewModelProtocol

  func configure(with viewModel: ViewModelType)
}

class BaseViewController: UIViewController {

  // MARK: -

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.navigationBar.backItem?.title = " "
    self.extendedLayoutIncludesOpaqueBars = true
    self.edgesForExtendedLayout = UIRectEdge.bottom
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: -

  var disposeBag = DisposeBag()
}
