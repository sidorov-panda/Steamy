//
//  TextCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 05.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit

class TextCellItem: BaseCellItem {
  var text: String?
}

class TextCell: BaseCell {

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

    guard let item = item as? TextCellItem else {
      return
    }
    label.text = item.text
  }

  // MARK: -

  let label = UILabel(frame: .zero)

  func configureUI() {
    backgroundColor = .defaultBackgroundCellColor
    label.textColor = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
    label.font = .systemFont(ofSize: 14.0)
    label.numberOfLines = 0
    addSubview(label)

    label.snp.makeConstraints { (maker) in
      maker.leading.equalTo(self).offset(16)
      maker.trailing.equalTo(self).offset(-16)
      maker.top.equalTo(self).offset(16)
      maker.bottom.equalTo(self).offset(-16)
    }
  }
}
