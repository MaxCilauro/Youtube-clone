//
//  YoutubeResponse.swift
//  youtube-clone
//
//  Created by Yaku on 12/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct YoutubeResponse: Decodable {
  let kind: String
  let items: [YoutubeItem]
}

struct YoutubeItem: Decodable {
  let itemId: ItemId
  let kind: String
  let snippet: Snippet
  let statistics: Statistics?
  
  enum CodingKeys: String, CodingKey {
    case itemId = "id"
    case snippet
    case statistics
    case kind
  }
}

struct ItemId: Decodable {
  var id: String?
  var kind: String?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    do {
      id = try container.decode(String.self)
    } catch {
      let idDescription = try container.decode(IdDescription.self)
      id = idDescription.videoId ?? idDescription.channelId
      kind = idDescription.kind
    }
  }
}

struct IdDescription: Decodable {
  let kind: String
  let channelId: String?
  let videoId: String?
}

struct Snippet: Decodable {
  let title: String
  let channelId: String
  let description: String
  let publishedAt: String
  let thumbnails: Thumbnail
  let channelTitle: String
}

struct Statistics: Decodable {
  let viewCount: String
  let likeCount: String?
  let dislikeCount: String?
  let favoriteCount: String
  let commentCount: String?
  
  static let empty = Statistics(viewCount: "", likeCount: "", dislikeCount: "", favoriteCount: "", commentCount: "")
}

struct Thumbnail: Decodable {
  let medium: ThumbnailMetadata
  let high: ThumbnailMetadata
  let maxRes: ThumbnailMetadata?
  
  enum CodingKeys: String, CodingKey {
    case maxRes = "maxres"
    case medium
    case high
  }
}

struct ThumbnailMetadata: Decodable {
  let url: String
  let width: Int?
  let height: Int?
}
