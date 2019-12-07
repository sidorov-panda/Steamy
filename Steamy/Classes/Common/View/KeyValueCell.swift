//
//  KeyValueCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 05.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit

class KeyValueCellItem: BaseCellItem {
  var key: String?
  var value: String?
}

class KeyValueCell: BaseCell {

  // MARK: -

  var keyLabel = UILabel()
  var valueLabel = UILabel()

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

    guard let item = item as? KeyValueCellItem else {
      return
    }

    keyLabel.text = item.key
    valueLabel.text = item.value
  }

  // MARK: -

  func configureUI() {
    backgroundColor = .defaultBackgroundCellColor
    keyLabel.numberOfLines = 0
    keyLabel.textColor = .white
    keyLabel.font = UIFont.systemFont(ofSize: 14)
    valueLabel.numberOfLines = 0
    valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    valueLabel.textColor = .white
    valueLabel.textAlignment = .right
    addSubview(keyLabel)
    addSubview(valueLabel)

    keyLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(self).offset(16)
      maker.top.equalTo(self).offset(10)
    }

    valueLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(keyLabel.snp.trailing).offset(5)
      maker.top.equalTo(self).offset(10)
      maker.bottom.equalTo(self).offset(-10)
      maker.trailing.equalTo(self).offset(-16)
    }
  }

}
