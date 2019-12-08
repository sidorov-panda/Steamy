//
//  LoadingCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 08.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit

class LoadingCellItem: BaseCellItem {}

class LoadingCell: BaseCell {

  // MARK: -

  var spinner = UIActivityIndicatorView(style: .whiteLarge)

  // MARK: -

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    configureUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: -

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    spinner.startAnimating()
  }

  // MARK: -

  func configureUI() {
    backgroundColor = .defaultBackgroundCellColor
    addSubview(spinner)
    spinner.startAnimating()

    spinner.snp.makeConstraints { (maker) in
      maker.center.equalTo(self)
    }
  }

}
