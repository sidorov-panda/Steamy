//
//  RootViewController.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import UIKit
import SteamLogin
import SVProgressHUD
import RxSwift
import RxCocoa

class RootViewController: BaseViewController, ControllerProtocol {

  // MARK: - ControllerProtocol

  typealias ViewModelType = RootViewModel

  var viewModel: RootViewModel!

  func configure(with viewModel: RootViewModel) {
    self.viewModel = viewModel
  }

  // MARK: -

  func bind() {
    //Output
    viewModel
      .output
      .showLogin
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { (_) in
        let loginVC = SteamLoginVC(loginHandler: { [weak self] (user, error) in
          if let user = user {
            self?.viewModel.input.didReceiveSteamUser.onNext(user.steamID64)
          }
        })

        loginVC.modalPresentationStyle = .overCurrentContext
        let navigationVC = UINavigationController(rootViewController: loginVC)
        navigationVC.modalPresentationStyle = .fullScreen
        navigationVC.navigationBar.isTranslucent = false
        loginVC.navigationItem.rightBarButtonItem?.tintColor = .clear
        self.present(navigationVC, animated: false) {
          loginVC.navigationItem.rightBarButtonItems = nil
          loginVC.navigationItem.rightBarButtonItem = nil
        }
      }).disposed(by: disposeBag)

    viewModel
      .output
      .showProfile
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (profileVC) in
        if let profileVC = profileVC {
          self?.showViewControllerWith(profileVC, usingAnimation: .down) {}
        }
      }).disposed(by: disposeBag)

    // Input
    viewModel.input.viewDidLoad.onNext(())
  }

  // MARK: -

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .defaultBackgroundColor

    bind()
  }

  // MARK: -

  var animationStart = false
  var shoudShowAnimateTransition = false

  enum AnimationType {
    case right
    case left
    case up
    case down
  }

  func showViewControllerWith(_ newViewController: UIViewController,
                              usingAnimation animationType: AnimationType,
                              completion: (() -> ())?) {
    if animationStart {
      completion?()
      return
    }

    let currentViewController = self.children.last

    if nil != currentViewController {
      guard newViewController.classForCoder != currentViewController!.classForCoder else {
        completion?()
        return
      }
    }

    let width = self.view.frame.size.width
    let height = self.view.frame.size.height

    var previousFrame: CGRect?
    var nextFrame: CGRect?
    let initCurrentViewFrame = self.view.frame

    switch animationType {
    case .left:
      previousFrame = CGRect(x: width-1, y: 0.0, width: width, height: height)
      nextFrame = CGRect(x: -width, y: 0.0, width: width, height: height)

    case .right:
      previousFrame = CGRect(x: -width+1, y: 0.0, width: width, height: height)
      nextFrame = CGRect(x: width, y: 0.0, width: width, height: height)

    case .up:
      previousFrame = CGRect(x: 0.0, y: height-1, width: width, height: height)
      nextFrame = CGRect(x: 0.0, y: -height+1, width: width, height: height)

    case .down:
      previousFrame = CGRect(x: 0.0, y: -height+1, width: width, height: height)
      nextFrame = CGRect(x: 0.0, y: height-1, width: width, height: height)
    }

    self.addChild(newViewController)

    newViewController.view.frame = previousFrame!
    self.view.addSubview(newViewController.view)

    var duration = 0.33
    if currentViewController == nil {
      duration = 0.0
    }

    animationStart = true
    UIView.animate(withDuration: duration,
                   animations: { [weak currentViewController] () -> Void in
      newViewController.view.frame = initCurrentViewFrame
      if currentViewController != nil {
        currentViewController?.view.frame = nextFrame!
      }
    }, completion: { [weak self, currentViewController] (fihish: Bool) -> Void in
      if currentViewController != nil {
        currentViewController?.willMove(toParent: self)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
      }

      self?.didMove(toParent: newViewController)

      self?.shoudShowAnimateTransition = true
      self?.animationStart = false
      completion?()
    })
  }
}
