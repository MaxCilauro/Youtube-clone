//
//  VideoResponse.swift
//  youtube-clone
//
//  Created by Yaku on 18/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct VideoResponse: Decodable {
  var items: [VideoItem]
}

struct VideoItem: Decodable {
  let id: String
  let snippet: Snippet
  let statistics: VideoStatistics
}

struct VideoStatistics: Decodable {
  let viewCount: String
  let likeCount: String?
  let dislikeCount: String?
  let favoriteCount: String
  let commentCount: String?
  
  static let empty = VideoStatistics(viewCount: "", likeCount: "", dislikeCount: "", favoriteCount: "", commentCount: "")
}
