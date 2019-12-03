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

  var tiles = [UIView]()

  var scrollView = UIScrollView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.addSubview(scrollView)
    scrollView.snp.makeConstraints { (maker) in
      maker.height.equalTo(83)
      maker.leading.equalToSuperview()
      maker.trailing.equalToSuperview()
      maker.bottom.equalToSuperview().priority(.medium)
      maker.top.equalToSuperview()
    }

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

    var lastView: UIView?
    let views = makeTiles(item: item)
    for i in 0..<views.count {
      let view = views[i]
      let isTheLastOne = (i == views.count)
      scrollView.addSubview(view)

      view.snp.makeConstraints { (maker) in
        if lastView == nil {
          maker.leading.equalToSuperview().offset(16)
        } else {
          maker.leading.equalTo(lastView!.snp.trailing).offset(8)
        }
        maker.top.equalToSuperview()
        maker.bottom.equalToSuperview()
        maker.height.equalTo(83).priority(.medium)
        maker.width.equalTo(153)
        if isTheLastOne {
          maker.trailing.equalToSuperview()
        }
      }
      lastView = view
    }
  }

  func makeTiles(item: ShowcaseCellItem) -> [UIView] {
    var newTiles = [UIView]()

    let playedTile = makeTile(title: "Played",
                              value: "1000 h",
                              size: CGSize(width: 153, height: 83),
                              color: .blue)
    
    let playedTile1 = makeTile(title: "Played",
                              value: "1000 h",
                              size: CGSize(width: 153, height: 83),
                              color: .red)
    
    return [playedTile, playedTile1]
  }

  func makeTile(title: String, value: String, size: CGSize, color: UIColor) -> UIView {
    let view = UIView(frame: .zero)
    view.layer.cornerRadius = 6.0
    view.backgroundColor = color

    let titleLabel = UILabel(frame: .zero)
    titleLabel.text = title
    titleLabel.textColor = .white
    titleLabel.font = UIFont.systemFont(ofSize: 12.0)
    view.addSubview(titleLabel)

    titleLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(view).offset(8)
      maker.bottom.equalTo(view).offset(-8)
      maker.trailing.equalTo(view).offset(2)
    }

    let valueLabel = UILabel(frame: .zero)
    valueLabel.text = value
    valueLabel.textColor = .white
    view.addSubview(valueLabel)

    valueLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(view).offset(8)
      maker.top.equalTo(view).offset(8)
      maker.trailing.equalTo(view).offset(2)
    }
    return view
  }

}
