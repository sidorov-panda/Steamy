//
//  BaseManager.swift
//  Steamy
//
//  Created by Alexey Sidorov on 03.12.2019.
//  Copyright © 2019 Alexey Sidorov. All rights reserved.
//

import Foundation

class BaseManager {
  //var should be passed to a provider, so it can decide wheter it should return cached data or request for the new one
  //It's better to have this kind of var in every method, since the var is not reliable or async, but for simplicity reasons I'm keeping this
  //Please, use a separate instance of `cacheEnabled`-manager in sensitive places, or substitute this var by adding to methods.
//  var cacheEnabled: Bool = true
}
