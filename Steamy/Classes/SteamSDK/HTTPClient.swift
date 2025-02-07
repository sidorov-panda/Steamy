//
//  HTTPClient.swift
//  Steamy
//
//  Created by Alexey Sidorov on 23.11.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation
import Alamofire

class HTTPClient: HTTPClientProtocol {

  func getRequest(_ url: URL, params: [String: Any] = [:], refresh: Bool = false, completion: @escaping ((HTTPClientResponse) -> ())) {
    let request = URLRequest(url: url, cachePolicy: refresh ? .reloadIgnoringLocalAndRemoteCacheData : .returnCacheDataElseLoad, timeoutInterval: 25)
    Alamofire.request(request).responseJSON { (response) in
      completion((response.value, response.error))
    }
  }

  func postRequest(_ url: URL, params: [String: Any] = [:], completion: @escaping ((HTTPClientResponse) -> ())) {
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
      completion((response.value, response.error))
    }
  }
}
