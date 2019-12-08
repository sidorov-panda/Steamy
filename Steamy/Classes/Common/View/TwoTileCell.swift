//
//  TwoTileCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 04.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit

class TwoTileCellItem: BaseCellItem {
  var firstTileKey: String?
  var firstTileValue: String?
  var secondTileKey: String?
  var secondTileValue: String?
}

class TwoTileCell: BaseCell {

  // MARK: -

  var firstTile: TileView?
  var secondTile: TileView?

  // MARK: -

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    configureUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: -

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? TwoTileCellItem else {
      return
    }

    firstTile?.titleLabel.text = item.firstTileKey
    firstTile?.valueLabel.text = item.firstTileValue

    if item.secondTileKey != nil && item.secondTileValue != nil {
      secondTile?.titleLabel.text = item.secondTileKey
      secondTile?.valueLabel.text = item.secondTileValue
    } else {
      secondTile?.isHidden = true
    }
  }

  // MARK: -
  
  let wrapperView = UIView()

  func configureUI() {

    addSubview(wrapperView)
    wrapperView.snp.makeConstraints { (maker) in
      maker.leading.trailing.top.bottom.equalTo(self)
      maker.height.equalTo(90)
    }

    backgroundColor = .defaultBackgroundCellColor

    firstTile = TileView.makeTile(title: "",
                                  value: "",
                                  size: CGSize(width: 153, height: 83),
                                  color: UIColor(red: 0.165, green: 0.2, blue: 0.596, alpha: 1))

    secondTile = TileView.makeTile(title: "",
                                   value: "",
                                   size: CGSize(width: 153, height: 83),
                                   color: UIColor(red: 0.165, green: 0.2, blue: 0.596, alpha: 1))

    self.addSubview(firstTile!)
    self.addSubview(secondTile!)

    firstTile?.snp.makeConstraints { maker in
      maker.top.equalTo(self).offset(10)
      maker.leading.equalTo(self).offset(16)
      maker.width.equalTo(self).dividedBy(2).offset(-20)
      maker.height.equalTo(83)
    }

    secondTile?.snp.makeConstraints { maker in
      maker.leading.equalTo(firstTile!.snp.trailing).offset(8)
      maker.trailing.equalTo(self).offset(-16)
      maker.top.equalTo(firstTile!)
      maker.bottom.equalTo(firstTile!)
      maker.height.equalTo(firstTile!)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    firstTile?.titleLabel.text = nil
    firstTile?.valueLabel.text = nil
    secondTile?.titleLabel.text = nil
    secondTile?.valueLabel.text = nil
    secondTile?.isHidden = false
  }

}
