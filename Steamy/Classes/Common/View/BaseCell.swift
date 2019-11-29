//
//  BaseTableViewCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import AlamofireImage

protocol Configurable where Self: UITableViewCell {
  func configure(item: BaseCellItem)
}

typealias ConfigurableCell = UITableViewCell & Configurable

public class BaseCellItem: IdentifiableType, Equatable {

  ///Academicaly it's no good to store reuse here, it's better to have it in some kind of tableView managment structure, but for simplicity reasons
  let reuseIdentifier: String
  let identifier: String

  init(reuseIdentifier: String, identifier: String) {
    self.reuseIdentifier = reuseIdentifier
    self.identifier = identifier
  }

  // MARK: - IdentifiableType

  public typealias Identity = String

  public var identity : Identity {
    return identifier
  }

  // MARK: - Equatable

  public static func == (lhs: BaseCellItem, rhs: BaseCellItem) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

class BaseCell: ConfigurableCell {

  // MARK: -

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.selectionStyle = .none
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: -

  var disposeBag = DisposeBag()

  func configure(item: BaseCellItem) {}

  // MARK: -

  override func prepareForReuse() {
    super.prepareForReuse()
    ///clearing bag after reuse
    disposeBag = DisposeBag()
  }
}
