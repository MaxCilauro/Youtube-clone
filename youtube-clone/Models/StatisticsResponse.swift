//
//  StatisticsResponse.swift
//  youtube-clone
//
//  Created by Yaku on 18/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct StatisticsResponse: Decodable {
  var items: [StatisticsItem]
}

struct StatisticsItem: Decodable {
  let statistics: Statistics
}
