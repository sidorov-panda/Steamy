//
//  TitleCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class TitleCellItem: BaseCellItem {
  var title: String?
}

class TitleCell: BaseCell {

  // MARK: -

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  // MARK: - Configurable

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? TitleCellItem else {
      return
    }
    self.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
    self.textLabel?.text = item.title
  }
}
