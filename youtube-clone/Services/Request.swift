//
//  Request.swift
//  youtube-clone
//
//  Created by Yaku on 01/10/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class Request {
  enum RequestError: Error {
    case invalidJSON
    case invalidURL(string: String?)
  }
  
  static func fetch (url: URL) -> Observable<Data> {
    URLSession.shared.rx
      .data(request: URLRequest(url: url))
      .observeOn(MainScheduler.instance)
  }
  
  static func fetchJSON<T: Decodable>(url: URL) -> Observable<T> {
    fetch(url: url).map { (data) -> T in
      guard let response = try? JSONDecoder().decode(T.self, from: data) else {
        throw RequestError.invalidJSON
      }
      print(response)
      return response
    }
    .observeOn(MainScheduler.instance)
  }
}
