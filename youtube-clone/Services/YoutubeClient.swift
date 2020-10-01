//
//  YoutubeManager.swift
//  youtube-clone
//
//  Created by Yaku on 15/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation
import Alamofire

class YoutubeClient {
  static let apiKey = "AIzaSyAS_uiGtS1N0pwoRYxciYZ-l-xXHZEuMnE"
  var searchItems: [Item] = []
  var channelImages: [String: Data] = [:]
  var videoMetadata: [String: VideoStatistics] = [:]
  
  enum Endpoints {
    static let base = "https://www.googleapis.com/youtube/v3"
    static let apiKeyParam = "?key=\(apiKey)"
    
    case search(q: String)
    case channels(id: String)
    case videos(id: String)
    
    var stringValue: String {
      switch self {
      case .search(let q):
        return Endpoints.base + "/search" + Endpoints.apiKeyParam + "&part=snippet&q=\(q)"
      case .channels(let id):
        return Endpoints.base + "/channels" + Endpoints.apiKeyParam + "&part=snippet&id=\(id)"
      case .videos(let id):
        return Endpoints.base + "/videos" + Endpoints.apiKeyParam + "&part=statistics&id=\(id)"
      }
    }
    
    var url: URL {
      return URL(string: stringValue)!
    }
  }
  
  func search(q: String, completionHandler: @escaping (Bool) -> Void) {
    AF.request(Endpoints.search(q: q).url)
      .responseDecodable(of: Search.self) { response in
        guard let video = response.value else {
          completionHandler(false)
          return
        }
        self.searchItems = video.items.filter({ (item) -> Bool in
          item.id.videoId != nil
        })
        self.loadImages(completionHandler: completionHandler)
      }
  }
  
  func loadImages(completionHandler: @escaping (Bool) -> Void) {
    // this looks terrible
    let group = DispatchGroup() // refactor to use Rx or Combine
    var channelImages: [String] = []
    var videoIds: [String] = []
    
    for (index, item) in self.searchItems.enumerated() {
      group.enter()
      AF.request(item.snippet.thumbnails.medium.url).response { (response) in
        self.searchItems[index].snippet.thumbnails.medium.image = response.data
        group.leave()
      }
      
      if let videoId = item.id.videoId {
        videoIds.append(videoId)
      }
      
      if channelImages.contains(item.snippet.channelId) {
        continue
      }
      
      channelImages.append(item.snippet.channelId)
    }
    
    let channelsUrl = Endpoints.channels(id: channelImages.joined(separator: ",")).url
    group.enter()
    AF.request(channelsUrl).responseDecodable(of: Channel.self) { response in
      guard let channels = response.value else {
        group.leave()
        return
      }
      
      channels.items.forEach { (item) in
        group.enter()
        AF.request(item.snippet.thumbnails.medium.url).response { (response) in
          self.channelImages[item.id] = response.data
          group.leave()
        }
      }
      group.leave()
    }
    
    let videosUrl = Endpoints.videos(id: videoIds.joined(separator: ",")).url
    group.enter()
    AF.request(videosUrl).responseDecodable(of: Video.self) { response in
      guard let videos = response.value else {
        group.leave()
        return
      }
      
      videos.items.forEach { (item) in
        self.videoMetadata[item.id] = item.statistics
      }
      group.leave()
    }
    
    group.notify(queue: .main) {
      for (index, _) in self.searchItems.enumerated() {
        self.searchItems[index].snippet.channelImage = self.channelImages[self.searchItems[index].snippet.channelId]
        self.searchItems[index].id.statistics = self.videoMetadata[self.searchItems[index].id.videoId ?? ""]
      }
      
      completionHandler(true)
    }
  }
}
