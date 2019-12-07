//
//  AchievementCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 07.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import AlamofireImage

class AchievementCellItem: BaseCellItem {
  var title: String?
  var imageURL: URL?
  var placeholderImage: UIImage? = UIImage(named: "gamePlaceholderSmall")?
  .af_imageScaled(to: CGSize(width: 30, height: 30))
}

class AchievementCell: BaseCell {

  // MARK: -

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    configureUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: -

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? AchievementCellItem else {
      return
    }
    textLabel?.text = item.title
    textLabel?.textColor = .white
    if let imageURL = item.imageURL {
      imageView?.layer.cornerRadius = 3
      imageView?.af_setImage(withURL: imageURL,
                             placeholderImage: item.placeholderImage,
                             filter: ScaledToSizeFilter(size: CGSize(width: 30, height: 30)))
    }
  }

  // MARK: -

  func configureUI() {
    backgroundColor = .defaultBackgroundCellColor
    textLabel?.numberOfLines = 0
    textLabel?.textColor = .white
    textLabel?.font = UIFont.systemFont(ofSize: 14)
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    imageView?.image = UIImage(named: "gamePlaceholderSmall")?
      .af_imageScaled(to: CGSize(width: 30, height: 30))
    textLabel?.text = nil
  }
}
