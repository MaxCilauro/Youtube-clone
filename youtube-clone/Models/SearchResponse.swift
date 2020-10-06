//
//  SearchResponse.swift
//  youtube-clone
//
//  Created by Yaku on 12/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct SearchResponse: Decodable {
  let kind: String
  let items: [SearchItem]
  
  static let empty = SearchResponse(kind: "", items: [])
}

struct SearchItem: Decodable {
  let snippet: Snippet
}

struct Snippet: Decodable {
  let title: String
  let channelId: String
  let description: String
  let publishedAt: String
  let thumbnails: Thumbnail
  let channelTitle: String
}

struct Thumbnail: Decodable {
  let medium: ThumbnailInfo
  let high: ThumbnailInfo
}

struct ThumbnailInfo: Decodable {
  let url: String
  let width: Int?
  let height: Int?
}

struct SearchVideoInfo: Decodable {
  let videoId: String?
}
