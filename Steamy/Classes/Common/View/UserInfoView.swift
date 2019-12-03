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
}

class UserInfoView: UIView {

  let disposeBag = DisposeBag()

  var nameLabel: UILabel!
  var locationLabel: UILabel!
  var levelLabel: UILabel!
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
    item.nameObservable.asDriver(onErrorJustReturn: nil).drive(nameLabel.rx.text).disposed(by: disposeBag)
    item.locationObservable.asDriver(onErrorJustReturn: nil).drive(locationLabel.rx.text).disposed(by: disposeBag)
    item.levelObservable.asDriver(onErrorJustReturn: nil).drive(levelLabel.rx.text).disposed(by: disposeBag)
    item.avatarObservable.asDriver(onErrorJustReturn: nil).drive(onNext: { [weak self] (url) in
      if let url = url {
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
          size: self?.avatarImageView.frame.size ?? .zero,
          radius: 10
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
    addSubview(levelLabel)

    nameLabel = UILabel()
    nameLabel.text = ""
    nameLabel.textColor = .white
    addSubview(nameLabel)

    avatarImageView = UIImageView()
    avatarImageView.layer.cornerRadius = 10
    avatarImageView.backgroundColor = .clear
    addSubview(avatarImageView)

    locationLabel = UILabel()
    locationLabel.textColor = .white
    addSubview(locationLabel)

    avatarImageView.snp.makeConstraints { (maker) in
      maker.height.equalTo(83)
      maker.width.equalTo(83)
      maker.trailing.equalTo(self.snp.trailing).offset(-16)
      maker.top.equalTo(self).offset(0)
    }

    levelLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(self).offset(0)
      maker.left.equalTo(self).offset(16)
      maker.trailing.equalTo(avatarImageView).offset(-5)
    }

    nameLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(levelLabel.snp.bottom)
      maker.leading.equalTo(levelLabel.snp.leading)
      maker.trailing.equalTo(avatarImageView).offset(-5)
    }

    locationLabel.snp.makeConstraints { (maker) in
      maker.top.equalTo(nameLabel.snp.bottom)
      maker.leading.equalTo(nameLabel)
    }
  }
}
