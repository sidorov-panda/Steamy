//
//  Sugar.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

extension Array {
  public subscript (safe index: Int) -> Element? {
    return indices ~= index ? self[index] : nil
  }
}

extension Array {
  subscript(safe range: Range<Index>) -> [Element]? {
    guard range.lowerBound >= self.startIndex else { return nil }
    guard range.upperBound <= self.endIndex else { return Array(self) }
    
    return Array(self[range])
  }
}
