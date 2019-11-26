//
//  GameViewController.swift
//  Steamy
//
//  Created by Alexey Sidorov on 25.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlamofireImage
import SVProgressHUD
import RxDataSources
import ImageSlideshow

class GameViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = GameViewModel

  var viewModel: GameViewModel!

  func configure(with viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  // MARK: -

  func bind() {
    //Output
    viewModel
      .output
      .sections
      .bind(to: tableView.rx.items(dataSource: rxDataSource!))
      .disposed(by: disposeBag)

    viewModel
      .output
      .backgroundImage
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (url) in
        if let url = url {
          self?.backgroundImage.af_setImage(withURL: url)
        }
      }).disposed(by: disposeBag)

    viewModel
      .output
      .title
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (title) in
        self?.title = title
      }).disposed(by: disposeBag)

    viewModel
      .output
      .isLoading
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { (val) in
        if val {
          SVProgressHUD.show()
        } else {
          SVProgressHUD.dismiss()
        }
      }).disposed(by: disposeBag)

    //Input
    viewModel.input.viewDidLoad.onNext(())
  }

  // MARK: -

  var tableView = UITableView()
  var backgroundImage = UIImageView()

  var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .red

    configureUI()
    registerCells()

    rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseTableSectionItem>(
      configureCell: { dataSource, tableView, indexPath, sm in
        guard
          let item = try? dataSource.model(at: indexPath) as? BaseCellItem,
          let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? ConfigurableCell else {
            return UITableViewCell()
        }
        cell.configure(item: item)
        return cell
    })

    rxDataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                  reloadAnimation: .automatic,
                                                                  deleteAnimation: .automatic)

    bind()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isTranslucent = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isTranslucent = true
  }

  func registerCells() {
    self.tableView.register(GameInfoCell.self, forCellReuseIdentifier: "GameInfoCell")
  }

  // MARK: -
  
  let slideshow = ImageSlideshow(frame: CGRect(x: 0, y: 0, width: 10, height: 100))

  func configureUI() {
    tableView.backgroundColor = .clear
    tableView.tableFooterView = UIView()

    backgroundImage.contentMode = .scaleAspectFill
    backgroundImage.clipsToBounds = true
    view.addSubview(backgroundImage)
    backgroundImage.snp.makeConstraints { (maker) in
      maker.top.equalTo(self.view)
      maker.leading.equalTo(self.view)
      maker.trailing.equalTo(self.view)
      maker.bottom.equalTo(self.view)
    }

    view.addSubview(tableView)
    tableView.snp.makeConstraints { (maker) in
      maker.top.equalTo(self.view)
      maker.left.equalTo(self.view)
      maker.right.equalTo(self.view)
      maker.bottom.equalTo(self.view)
    }

//    slideshow.snp.makeConstraints { (maker) in
//      maker.leading.equalToSuperview()
//      maker.trailing.equalToSuperview()
//      maker.top.equalToSuperview()
//      maker.height.equalTo(70)
//      maker.bottom.equalToSuperview()
//    }

    slideshow.backgroundColor = .red
    tableView.tableHeaderView = slideshow
  }

}