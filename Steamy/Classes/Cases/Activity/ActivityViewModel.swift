//
//  ProfileViewModel.swift
//  Steamy
//
//  Created by Alexey Sidorov on 24.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import RxSwift

class ActivityViewModel: BaseViewModel, ViewModelProtocol {

  // MARK: - ViewModelProtocol

  struct Input {
    
  }

  struct Output {
    var sections: Observable<[BaseTableSectionItem]>
  }

  var input: ActivityViewModel.Input!
  var output: ActivityViewModel.Output!

  override init() {
    input = Input()
    output = Output(sections: sectionsSubject.asObservable())

    super.init()
  }

  // MARK: -

  private var sectionsSubject = PublishSubject<[BaseTableSectionItem]>()
  
  // MARK: -

  func createSections() {
    
  }
}
