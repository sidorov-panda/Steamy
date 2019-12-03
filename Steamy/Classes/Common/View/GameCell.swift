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
  var placeholderImage: UIImage? = UIImage(named: "gamePlaceholderSmall")?
    .af_imageScaled(to: CGSize(width: 30, height: 30))
}

class GameCell: BaseCell {

  // MARK: -

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.backgroundColor = .defaultBackgroundCellColor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configurable

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? GameCellItem else {
     return
    }

    self.textLabel?.text = item.name
    self.textLabel?.textColor = .white
    if let imageURL = item.iconURL {
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
