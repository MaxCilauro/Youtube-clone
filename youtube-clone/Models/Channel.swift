//
//  Channel.swift
//  youtube-clone
//
//  Created by Yaku on 03/10/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation
import UIKit

struct Channel {
  let id: String
  let image: UIImage?
  let title: String
  let description: String
  
  static let empty = Channel(id: "", image: nil, title: "", description: "")
}
