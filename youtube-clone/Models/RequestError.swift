//
//  RequestError.swift
//  youtube-clone
//
//  Created by Yaku on 30/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

enum RequestError: Error {
  case invalidJSON
  case invalidURL(s: String?)
}
