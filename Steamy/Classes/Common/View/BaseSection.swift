//
//  BaseSection.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxDataSources

struct BaseTableSectionItem: AnimatableSectionModelType, IdentifiableType, Equatable {

  static func == (lhs: BaseTableSectionItem, rhs: BaseTableSectionItem) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  var identifier = String.random(length: 20)

  var header: String? = ""

  var items: [BaseCellItem]

  init(header: String? = "", items: [BaseCellItem] = []) {
    self.header = header
    self.items = items
  }

  // MARK: -

  var identity: String {
    return identifier
  }

  typealias Identity = String

  typealias Item = BaseCellItem

  init(original: BaseTableSectionItem, items: [Item]) {
    self = original
    self.items = items
  }
}
