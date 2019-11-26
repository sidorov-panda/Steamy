//
//  GameInfoCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class GameInfoCellItem: BaseCellItem {
  var attributedText: NSAttributedString?
}

class GameInfoCell: BaseCell {

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  // MARK:  -
  
  override func configure(item: BaseCellItem) {
    super.configure(item: item)
    
    guard let item = item as? GameInfoCellItem else {
      return
    }
    self.textLabel?.attributedText = item.attributedText
    self.textLabel?.numberOfLines = 0
  }

}
