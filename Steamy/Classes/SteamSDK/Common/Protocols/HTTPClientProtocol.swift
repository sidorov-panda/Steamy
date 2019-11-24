//
//  HTTPClientProtocol.swift
//  Steamy
//
//  Created by Alexey Sidorov on 22.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

protocol HTTPClientProtocol {
  typealias HTTPClientResponse = (Any?, Error?)
  func getRequest(_ url: URL, params: [String: Any], completion: @escaping ((HTTPClientResponse) -> ()))
  func postRequest(_ url: URL, params: [String: Any], completion: @escaping ((HTTPClientResponse) -> ()))
}
