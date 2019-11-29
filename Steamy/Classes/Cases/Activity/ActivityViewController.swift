//
//  ProfileViewController.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import XLPagerTabStrip
import RealmSwift
import Charts
import SnapKit

class ActivityViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = ActivityViewModel

  func configure(with viewModel: ActivityViewModel) {
    self.viewModel = viewModel
  }

  var viewModel: ActivityViewModel!

  let barChartView = BarChartView()

  // MARK: -

  let realm = try! Realm()

  override func viewDidLoad() {
    super.viewDidLoad()

    let userId = Session.shared.userId!

    let data = realm.objects(GameStatDB.self).filter("user=%@", String(userId))

    var entries = [BarChartDataEntry]()
    data.forEach { (stat) in
      let xx = Int(stat.date ?? "") ?? 0
      entries.append(
        BarChartDataEntry(x: Double(xx), yValues: [Double(Int(stat.value!) ?? 0)])
      )
    }
    let dataset = BarChartDataSet(entries: entries, label: "HZZZ")
    let chartData = BarChartData(dataSet: dataset)
    
    barChartView.data = chartData

    view.addSubview(barChartView)
    barChartView.snp.makeConstraints { (maker) in
      maker.leading.equalTo(self.view)
      maker.trailing.equalTo(self.view)
      maker.top.equalTo(self.view)
      maker.height.equalTo(100)
    }

  }
}

extension ActivityViewController: IndicatorInfoProvider {
  public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Activity")
  }
}
