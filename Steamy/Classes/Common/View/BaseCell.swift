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

protocol Configurable where Self: UITableViewCell {
  func configure(item: BaseCellItem)
}

typealias ConfigurableCell = UITableViewCell & Configurable

public class BaseCellItem: IdentifiableType, Equatable {

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

  var disposeBag = DisposeBag()

  func configure(item: BaseCellItem) {}

  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
}
