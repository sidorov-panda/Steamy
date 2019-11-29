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

    self.addSubview(gameImageView)
    gameImageView.contentMode = .scaleAspectFit
    gameImageView.clipsToBounds = true
    gameImageView.snp.makeConstraints { (maker) in
      maker.height.equalTo(80)
      maker.leading.equalTo(self)
      maker.trailing.equalTo(self)
      maker.top.equalTo(self)
      maker.bottom.equalTo(self).priority(.medium)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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

    guard let item = item as? FavoriteGameCellItem else {
      return
    }
    gameImageView.image = item.image
  }
  
  // MARK: -
  
  override func prepareForReuse() {
    super.prepareForReuse()

    gameImageView.image = nil
  }
}
