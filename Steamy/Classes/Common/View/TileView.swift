//
//  TileView.swift
//  Steamy
//
//  Created by Alexey Sidorov on 04.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class TileView: UIView {

  var titleLabel: UILabel! = UILabel(frame: .zero)
  var valueLabel: UILabel! = UILabel(frame: .zero)

  static func makeTile(title: String, value: String, size: CGSize, color: UIColor) -> TileView {
    let view = TileView(frame: CGRect(origin: .zero, size: size))
    view.layer.cornerRadius = 6.0
    view.backgroundColor = color

    view.titleLabel.text = title
    view.titleLabel.adjustsFontSizeToFitWidth = true
    view.titleLabel.textColor = .white
    view.titleLabel.font = UIFont.systemFont(ofSize: 12.0)
    view.addSubview(view.titleLabel)

    view.titleLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(view).offset(8)
      maker.trailing.equalTo(view).offset(-5)
      maker.bottom.equalTo(view).offset(-8)
    }

    view.valueLabel.adjustsFontSizeToFitWidth = true
    view.valueLabel.text = value
    view.valueLabel.font = UIFont.systemFont(ofSize: 28.0)
    view.valueLabel.adjustsFontSizeToFitWidth = true
    view.valueLabel.numberOfLines = 0
    view.valueLabel.minimumScaleFactor = 0.1
    view.valueLabel.textColor = .white
    view.addSubview(view.valueLabel)

    view.valueLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(view).offset(8)
      maker.top.equalTo(view).offset(8)
      maker.trailing.equalTo(view).offset(-5)
      maker.bottom.lessThanOrEqualTo(view.titleLabel.snp.top).offset(2)
    }
    return view
  }
}
