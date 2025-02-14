//
//  UserInfoView.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import AlamofireImage

struct UserInfoViewItem {
  var nameObservable: Observable<String?>
  var locationObservable: Observable<String?>
  var levelObservable: Observable<String?>
  var avatarObservable: Observable<URL?>
  var onlineObservable: Observable<Bool>
}

class UserInfoView: UIView {

  let disposeBag = DisposeBag()

  // MARK: -

  var nameLabel: UILabel!
  var locationLabel: UILabel!
  var levelLabel: UILabel!
  var onlineLabel: UILabel!
  var avatarImageView: UIImageView!

  // MARK: -

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure

  func configure(item: UserInfoViewItem) {
    item.nameObservable
      .asDriver(onErrorJustReturn: nil)
      .drive(nameLabel.rx.text)
      .disposed(by: disposeBag)

    item.locationObservable.asDriver(onErrorJustReturn: nil)
      .drive(locationLabel.rx.text)
      .disposed(by: disposeBag)

//    item.levelObservable
//      .asDriver(onErrorJustReturn: nil)
//      .drive(levelLabel.rx.text)
//      .disposed(by: disposeBag)

    Observable
      .combineLatest(item.levelObservable, item.onlineObservable)
      .asDriver(onErrorJustReturn: (nil, false))
      .drive(onNext: { [weak self] (val) in
        let (level, isOnline) = val
        self?.onlineLabel.text = isOnline ? "Online" : ""
        self?.levelLabel.text = (level ?? "") + (isOnline ? " - " : "")
    }).disposed(by: disposeBag)

    item.avatarObservable
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (url) in
        if let url = url {
          let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: CGSize(width: 83, height: 83),
            radius: 41
          )
          self?.avatarImageView.af_setImage(
            withURL: url,
            placeholderImage: UIImage(named: "gamePlaceholderSmall"),
            filter: filter,
            imageTransition: .crossDissolve(0.2)
          )
        } else {
          self?.avatarImageView.image = UIImage(named: "gamePlaceholderSmall")
        }
      }).disposed(by: disposeBag)
  }

  // MARK: -

  func configureUI() {
    levelLabel = UILabel()
    levelLabel.text = ""
    levelLabel.textColor = .white
    levelLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    addSubview(levelLabel)

    nameLabel = UILabel()
    nameLabel.text = ""
    nameLabel.textColor = .white
    nameLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
    nameLabel.adjustsFontSizeToFitWidth = true
    addSubview(nameLabel)

    avatarImageView = UIImageView()
    avatarImageView.layer.cornerRadius = 41
    avatarImageView.backgroundColor = .clear
    avatarImageView.clipsToBounds = true
    avatarImageView.contentMode = .scaleAspectFill
    addSubview(avatarImageView)

    locationLabel = UILabel()
    locationLabel.textColor = UIColor(red: 0.318, green: 0.318, blue: 0.341, alpha: 1)
    locationLabel.font = UIFont.systemFont(ofSize: 12.0)
    addSubview(locationLabel)

    onlineLabel = UILabel()
    onlineLabel.textColor = .green
    onlineLabel.font = UIFont.systemFont(ofSize: 12)
    addSubview(onlineLabel)

    avatarImageView.snp.makeConstraints { (maker) in
      maker.height.equalTo(83)
      maker.width.equalTo(83)
      maker.trailing.equalTo(self.snp.trailing).offset(-16)
      maker.top.equalTo(self).offset(0)
    }

    levelLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(self).offset(0)
      maker.left.equalTo(self).offset(16)
      maker.height.greaterThanOrEqualTo(15)
    }

    onlineLabel.snp.makeConstraints { (maker) in
      maker.top.bottom.equalTo(levelLabel)
      maker.leading.equalTo(levelLabel.snp.trailing).offset(0)
    }

    nameLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(levelLabel.snp.bottom).offset(3)
      maker.leading.equalTo(levelLabel.snp.leading)
      maker.trailing.equalTo(avatarImageView.snp.leading).offset(0)
    }

    locationLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(nameLabel.snp.bottom).offset(3)
      maker.leading.equalTo(nameLabel)
    }
  }
}
