//
//  ShowcaseCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 02.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit

class ShowcaseCellItem: BaseCellItem {
  var hoursPlayed: String?
  var badgesCount: Int?
  var gamesCount: Int?
  var friendsCount: Int?
  var groupsCount: Int?
}

class ShowcaseCell: BaseCell {

  // MARK: -

  var tiles = [TileView]()

  var scrollView = UIScrollView()

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

    guard let item = item as? ShowcaseCellItem else {
      return
    }
    //TODO: make titles customizable
    zip([["Played": item.hoursPlayed ?? "0 h"], ["Badges": "\(item.badgesCount ?? 0)"], ["Games": "\(item.gamesCount ?? 0)"]],
        tiles).forEach { (val, tile) in
          tile.valueLabel.text = val.values.first ?? ""
          tile.titleLabel.text = val.keys.first ?? ""
    }
  }

  func configureUI() {
    backgroundColor = .defaultBackgroundCellColor
    addSubview(scrollView)
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.snp.makeConstraints { (maker) in
      maker.height.greaterThanOrEqualTo(90)
      maker.leading.equalToSuperview()
      maker.trailing.equalToSuperview()
      maker.bottom.equalToSuperview().priority(.medium)
      maker.top.equalToSuperview().offset(16)
    }

    var lastView: UIView?
    self.tiles = makeTiles()
    for i in 0..<self.tiles.count {
      let view = self.tiles[i]
      let isTheLastOne = (i == self.tiles.count - 1)
      scrollView.addSubview(view)

      view.snp.makeConstraints { (maker) in
        if lastView == nil {
          maker.leading.equalToSuperview().offset(16)
        } else {
          maker.leading.equalTo(lastView!.snp.trailing).offset(8)
        }
        maker.top.equalToSuperview().offset(7)
        maker.bottom.equalToSuperview()
        maker.height.equalTo(view.bounds.height).priority(.medium)
        maker.width.equalTo(view.bounds.width)
        if isTheLastOne {
          maker.trailing.equalToSuperview()
        }
      }
      lastView = view
    }
  }

  func makeTiles() -> [TileView] {
    let playedTile = TileView.makeTile(title: "",
                                       value: "",
                                       size: CGSize(width: 153, height: 83),
                                       color: UIColor(red: 0.165, green: 0.2, blue: 0.596, alpha: 1))
    playedTile.valueLabel.numberOfLines = 1
    let friendsTile = TileView.makeTile(title: "",
                                        value: "",
                                        size: CGSize(width: 83, height: 83),
                                        color: UIColor(red: 0.18, green: 0.18, blue: 0.325, alpha: 1))
    friendsTile.valueLabel.numberOfLines = 1
    let gamesTile = TileView.makeTile(title: "",
                                      value: "",
                                      size: CGSize(width: 83, height: 83),
                                      color: UIColor(red: 0.18, green: 0.18, blue: 0.325, alpha: 1))
    gamesTile.valueLabel.numberOfLines = 1
    return [playedTile, friendsTile, gamesTile]
  }
}
