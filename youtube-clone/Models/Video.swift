//
//  Video.swift
//  youtube-clone
//
//  Created by Yaku on 03/10/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation
import UIKit

struct Video {
  let id: String
  let channelId: String
  let title: String
  let description: String
  let statistics: VideoStatistics
  let channel: Channel
  let thumbnail: UIImage?
  let publishedAt: String
  
  static let empty = Video(id: "", channelId: "", title: "", description: "", statistics: VideoStatistics.empty, channel: Channel.empty, thumbnail: nil, publishedAt: "")
}
