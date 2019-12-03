//
//  Int+Time.swift
//  Steamy
//
//  Created by Alexey Sidorov on 30.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

extension Int {
  func secondsToHoursMinutesSeconds() -> (Int, Int, Int) {
    return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
  }
}
