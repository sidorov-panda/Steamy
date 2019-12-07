//
//  ActivityCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 30.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit
import AlamofireImage

class ActivityCellItem: BaseCellItem {
  var gameName: String?
  var activityDesc: String?
  var gameIconURL: URL?
  var placeholderImage: UIImage? = UIImage(named: "gamePlaceholderSmall")?
    .af_imageScaled(to: CGSize(width: 30, height: 30))
}

class ActivityCell: BaseCell {

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

    imageView?.image = UIImage(named: "gamePlaceholderSmall")?
      .af_imageScaled(to: CGSize(width: 30, height: 30))
    backgroundColor = UIColor.defaultBackgroundCellColor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configurable

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? ActivityCellItem else {
     return
    }

    self.textLabel?.text = item.gameName
    self.textLabel?.numberOfLines = 0
    self.textLabel?.textColor = .white
    self.detailTextLabel?.text = item.activityDesc
    self.detailTextLabel?.textColor = UIColor(red: 0.57, green: 0.57, blue: 0.62, alpha: 1.0)
    self.detailTextLabel?.numberOfLines = 0
    if let imageURL = item.gameIconURL {
      self.imageView?.af_setImage(withURL: imageURL,
                                  filter: ScaledToSizeFilter(size: CGSize(width: 30, height: 30)))
    }
  }

  // MARK: -

  override func prepareForReuse() {
    super.prepareForReuse()

    self.imageView?.image = UIImage(named: "gamePlaceholderSmall")?
      .af_imageScaled(to: CGSize(width: 30, height: 30))
    self.textLabel?.text = nil
    self.detailTextLabel?.text = nil
  }
}
