//
//  Search.swift
//  youtube-clone
//
//  Created by Yaku on 12/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct Search: Decodable {
  let kind: String
  var items: [Item]
}

struct Item: Decodable {
  var id: SearchVideoInfo
  var snippet: Snippet
}

struct Snippet: Decodable {
  let title: String
  let channelId: String
  var channelImage: Data?
  let description: String
  let publishedAt: String
  var thumbnails: Thumbnail
  let channelTitle: String
}

struct Thumbnail: Decodable {
  var medium: ThumbnailInfo
  let high: ThumbnailInfo
}

struct ThumbnailInfo: Decodable {
  let url: String
  let width: Int?
  let height: Int?
  var image: Data?
}

struct SearchVideoInfo: Decodable {
  let videoId: String?
  var statistics: VideoStatistics?
}
