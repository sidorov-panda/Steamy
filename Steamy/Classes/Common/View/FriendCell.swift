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
  var status: String?
  var statusColor: UIColor?
  var placeholderImage: UIImage? = UIImage(named: "gamePlaceholderSmall")?
    .af_imageScaled(to: CGSize(width: 30, height: 30))
}

class FriendCell: BaseCell {

  // MARK: -

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = .defaultBackgroundCellColor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configurable

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? FriendCellItem else {
     return
    }

    self.textLabel?.text = item.name
    self.textLabel?.textColor = .white

    self.detailTextLabel?.text = item.status
    self.detailTextLabel?.textColor = item.statusColor ?? .white

    if let imageURL = item.avatarURL {
      self.imageView?.layer.cornerRadius = 15.0
      self.imageView?.clipsToBounds = true
      self.imageView?.af_setImage(withURL: imageURL,
                                  placeholderImage: item.placeholderImage,
                                  filter: ScaledToSizeFilter(size: CGSize(width: 30, height: 30)))
    }
  }

  // MARK: -

  override func prepareForReuse() {
    super.prepareForReuse()

    self.imageView?.image = UIImage(named: "gamePlaceholderSmall")?
      .af_imageScaled(to: CGSize(width: 30, height: 30))
    self.textLabel?.text = nil
  }
}
