//
//  Chart.swift
//  Steamy
//
//  Created by Alexey Sidorov on 26.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SnapKit

class ChartBar: UIView {

  var color: UIColor?
  var height: CGFloat?
  var width: CGFloat?
  var title: String?
  var titleColor: UIColor?
}

class ChartSegment: UIView {

  var bars = [ChartBar]()

  func addBar(bar: ChartBar) {
    
  }

}

class Chart: UIView {

  var scrollView = UIScrollView()

  struct ChartPoint {
    var title: String
    var values: [(String, Float)]
  }

  func make(points: [ChartPoint]) {
    
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func contentSize() -> CGSize {
    return CGSize()
  }
  
  // MARK: -
  
  func configureUI() {
    self.addSubview(scrollView)
    scrollView.snp.makeConstraints { (maker) in
      maker.leading.equalTo(self)
      maker.trailing.equalTo(self)
      maker.top.equalTo(self)
      maker.bottom.equalTo(self)
    }
  }
}
