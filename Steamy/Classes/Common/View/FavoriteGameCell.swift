//
//  FavoriteGameCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 29.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class FavoriteGameCellItem: BaseCellItem {
  var image: UIImage?
}

class FavoriteGameCell: BaseCell {

  // MARK: -

  var gameImageView = UIImageView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    configureUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configurable

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? FavoriteGameCellItem else {
      return
    }
    gameImageView.image = item.image
  }

  // MARK: -

  func configureUI() {
    backgroundColor = UIColor.defaultBackgroundCellColor
    self.addSubview(gameImageView)
    gameImageView.contentMode = .scaleAspectFit
    gameImageView.clipsToBounds = true
    gameImageView.snp.makeConstraints { (maker) in
      maker.leading.equalTo(self).offset(8)
      maker.trailing.greaterThanOrEqualTo(self).offset(-12)
      maker.topMargin.equalTo(self).offset(16)
      maker.bottomMargin.equalTo(self)
    }
  }

  // MARK: -

  override func prepareForReuse() {
    super.prepareForReuse()

    gameImageView.image = nil
  }
}
