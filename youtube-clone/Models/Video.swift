//
//  Video.swift
//  youtube-clone
//
//  Created by Yaku on 18/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct Video: Decodable {
  var items: [VideoInfo]
}

struct VideoInfo: Decodable {
  let id: String
  var statistics: VideoStatistics
}

struct VideoStatistics: Decodable {
  let viewCount: String
  let likeCount: String
  let dislikeCount: String
  let favoriteCount: String
  let commentCount: String
}
