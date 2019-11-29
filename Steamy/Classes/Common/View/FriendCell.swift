//
//  FriendCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 27.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import AlamofireImage

class FriendCellItem: BaseCellItem {
  var name: String?
  var avatarURL: URL?
}

class FriendCell: BaseCell {

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

    guard let item = item as? FriendCellItem else {
     return
    }

    self.textLabel?.text = item.name
    self.textLabel?.textColor = .black
    if let imageURL = item.avatarURL {
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
