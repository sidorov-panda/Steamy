//
//  GameCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import AlamofireImage

class GameCellItem: BaseCellItem {
  var name: String?
  var logoURL: URL?
  var iconURL: URL?
}

class GameCell: BaseCell {

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

    guard let item = item as? GameCellItem else {
     return
    }

    self.textLabel?.text = item.name
    self.textLabel?.textColor = .black
    if let imageURL = item.iconURL {
      self.imageView?.af_setImage(withURL: imageURL)
    }
  }

  // MARK: -

  override func prepareForReuse() {
    super.prepareForReuse()

    self.imageView?.image = nil
    self.textLabel?.text = nil
  }

}
