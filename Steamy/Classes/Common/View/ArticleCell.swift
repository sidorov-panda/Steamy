//
//  ArticleCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 06.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit

class ArticleCellItem: BaseCellItem {
  var title: String?
  var content: String?
  var author: String?
  var date: String?
}

class ArticleCell: BaseCell {

  // MARK: -

  var titleLabel = UILabel()
  var contentLabel = UILabel()
  var bottomLabel = UILabel()

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

    guard let item = item as? ArticleCellItem else {
      return
    }

    titleLabel.text = item.title
    contentLabel.text = item.content
    bottomLabel.text = (item.date ?? "") + " | \(item.author ?? "")"
  }

  func configureUI() {
    backgroundColor = .defaultBackgroundCellColor
    titleLabel.numberOfLines = 0
    titleLabel.font = .systemFont(ofSize: 14.0, weight: .bold)
    titleLabel.textColor = .white
    addSubview(titleLabel)
    contentLabel.numberOfLines = 5
    contentLabel.font = .systemFont(ofSize: 14)
    contentLabel.textColor = .white
    addSubview(contentLabel)
    bottomLabel.numberOfLines = 0
    bottomLabel.font = .systemFont(ofSize: 12)
    bottomLabel.textColor = UIColor(red: 0.29, green: 0.294, blue: 0.376, alpha: 1)
    addSubview(bottomLabel)

    titleLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(self).offset(8)
      maker.leading.equalTo(self).offset(16)
      maker.trailing.equalTo(self).offset(-10)
    }

    contentLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(titleLabel)
      maker.top.equalTo(titleLabel.snp.bottom).offset(8)
      maker.trailing.equalTo(self).offset(-16)
    }

    bottomLabel.snp.makeConstraints { (maker) in
      maker.leading.equalTo(titleLabel)
      maker.trailing.equalTo(titleLabel)
      maker.top.equalTo(contentLabel.snp.bottom).offset(8)
      maker.bottom.equalTo(self).offset(-8)
    }
  }

}
