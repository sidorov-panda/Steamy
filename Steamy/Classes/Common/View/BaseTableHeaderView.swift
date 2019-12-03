//
//  BaseTableHeaderView.swift
//  Steamy
//
//  Created by Alexey Sidorov on 29.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit

class BaseTableHeaderView: UITableViewHeaderFooterView {

  var titleLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    self.backgroundColor = UIColor.defaultBackgroundCellColor

    self.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(self).offset(10)
      maker.trailing.equalTo(self)
      maker.top.equalTo(self).offset(20)
      maker.bottom.equalTo(self)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: -

  func configure(item: BaseTableSectionItem) {
    self.titleLabel.text = item.header
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.titleLabel.text = nil
  }
}
