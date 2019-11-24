//
//  BaseViewModel.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift

protocol ViewModelProtocol {
  associatedtype Input
  associatedtype Output

  var input: Input! { get }
  var output: Output! { get }
}

class BaseViewModel {

  var disposeBag = DisposeBag()

}
