//
//  ChartCell.swift
//  Steamy
//
//  Created by Alexey Sidorov on 01.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import Charts

class ChartCellItem: BaseCellItem {
  // "21 Dec": ["kills": ("Enemy Kills", UIColor.red, 245)]
  var data: [Date: [String: (String, UIColor, Int)]]?
  var numberOfItemsPerPage: Int = 2
}

class ChartCell: BaseCell {

  // MARK: -

  var chartView = BarChartView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    backgroundColor = .defaultBackgroundCellColor

    self.addSubview(chartView)
    chartView.snp.makeConstraints { (maker) in
      maker.leading.equalTo(self)
      maker.trailing.equalTo(self)
      maker.top.equalTo(self)
      maker.bottom.equalTo(self).priority(.medium)
      maker.height.equalTo(260)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: -

  override func configure(item: BaseCellItem) {
    super.configure(item: item)

    guard let item = item as? ChartCellItem else {
      return
    }

    let referenceTimeInterval: TimeInterval = (item.data?.keys.min() ?? Date()).timeIntervalSince1970

    var colors: [String: UIColor] = [:]
    var titles: [String: String] = [:]
    let days = (item.data ?? [:]).keys.count
    var maxYValue = 0.0
    var minXValue = 0.0
    var entries: [String: [BarChartDataEntry]] = [:]
    (item.data ?? [:]).keys.sorted(by: { (date1, date2) -> Bool in
      return date1 <   date2
    }).forEach { (key) in
      let xx = key.timeIntervalSince1970
      let xValue = (xx - referenceTimeInterval) / (3600 * 24)
      minXValue = (xx < minXValue) ? xx : minXValue
      item.data?[key]?.keys.forEach({ (name) in
        if let val = item.data?[key]?[name] {
          if entries[name] == nil {
            entries[name] = []
          }
          titles[name] = val.0
          colors[name] = val.1
          entries[name]?.append(BarChartDataEntry(x: xValue, y: Double(val.2)))
          maxYValue = max(maxYValue, Double(val.2))
        }
      })
    }

    var chartDataSets: [BarChartDataSet] = []
    for (key, value) in entries {
      let chartDataSet = BarChartDataSet(entries: value, label: titles[key] ?? key)
      chartDataSet.valueColors = [UIColor(red: 0.569, green: 0.573, blue: 0.624, alpha: 1)]
      if let color = colors[key] {
        chartDataSet.colors = [color]
      }
      chartDataSets.append(chartDataSet)
    }

    let chartData = BarChartData(dataSets: chartDataSets)

    // (0.2 + 0.03) * 2 + 0.54 = 1.00
    let barSpace = 0.05
    let barWidth = 0.3
    let groupSpace = 0.3
    chartData.barWidth = barWidth

    let gpWidth = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)

    chartView.xAxis.axisMinimum = Double(0)
    chartView.xAxis.axisMaximum = Double(0) + gpWidth * Double(days)
    chartData.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
    chartView.setVisibleXRange(minXRange: Double(0), maxXRange: Double(item.numberOfItemsPerPage))
    chartView.data = chartData

    chartView.moveViewToX(Double(days))

    // Define chart xValues formatter
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    formatter.locale = Locale.current

    let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)

    let xAxis = chartView.xAxis
    xAxis.labelPosition = .topInside
    xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
    xAxis.labelTextColor = .white
    xAxis.drawAxisLineEnabled = false
    xAxis.drawGridLinesEnabled = true
    xAxis.centerAxisLabelsEnabled = true
    xAxis.granularity = 1
    xAxis.valueFormatter = xValuesNumberFormatter

    let rightYAxis = chartView.rightAxis
    rightYAxis.labelPosition = .insideChart
    rightYAxis.drawLabelsEnabled = false
    rightYAxis.drawGridLinesEnabled = false
    rightYAxis.spaceMax = 20
    rightYAxis.axisMaximum = maxYValue + 200

    let leftYAxis = chartView.leftAxis
    leftYAxis.labelPosition = .insideChart
    leftYAxis.drawLabelsEnabled = false
    leftYAxis.drawGridLinesEnabled = false
    leftYAxis.spaceMax = 20
    leftYAxis.axisMaximum = maxYValue + 200

    chartView.legend.textColor = UIColor(red: 0.29, green: 0.294, blue: 0.376, alpha: 1)
    chartView.notifyDataSetChanged()
  }
}
