//
//  YoutubeManager.swift
//  youtube-clone
//
//  Created by Yaku on 15/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import RxSwift
import RxCocoa

class YoutubeClient {
  static let apiKey = "AIzaSyAS_uiGtS1N0pwoRYxciYZ-l-xXHZEuMnE"
  
  enum Endpoints {
    static let base = "https://www.googleapis.com/youtube/v3"
    static let apiKeyParam = "?key=\(apiKey)"
    
    case search(q: String)
    case channels(id: String)
    case videos(id: String)
    case popular
    
    var stringValue: String {
      switch self {
      case .search(let q):
        return Endpoints.base + "/search" + Endpoints.apiKeyParam + "&part=snippet&q=\(q)"
      case .channels(let id):
        return Endpoints.base + "/channels" + Endpoints.apiKeyParam + "&part=snippet&id=\(id)"
      case .videos(let id):
        return Endpoints.base + "/videos" + Endpoints.apiKeyParam + "&part=statistics&id=\(id)"
      case .popular:
        return Endpoints.base + "/videos" + Endpoints.apiKeyParam + "&part=statistics,snippet&chart=mostPopular"
      }
    }
    
    var url: URL? {
      return URL(string: stringValue)
    }
  }
  
  func getMostPopularVideos() -> Observable<VideoItem> {
    guard let url = Endpoints.popular.url else { return Observable.empty() }
    let videoResponse: Observable<VideoResponse> = Request.fetchJSON(url: url)
    let videoItems = videoResponse
      .flatMap { (response) -> Observable<VideoItem> in
        Observable.from(response.items)
      }
    let channels: Observable<[ChannelItem]> = channelsWithThumbnailsFrom(videoItems: videoItems)
      .reduce([]) { (acc, channelItem) -> [ChannelItem] in
        acc + [channelItem]
      }
    
    let items = videosWithThumbnailsFrom(videoItems: videoItems)
    
    return Observable.combineLatest(items, channels).flatMap { (videoItem, channels) -> Observable<VideoItem> in
      guard let currentChannel = channels.first(where: { $0.id == videoItem.snippet.channelId }) else {
        return Observable.of(videoItem)
      }
      
      var currentVideoItem = videoItem
      currentVideoItem.snippet.channelImage = currentChannel.snippet.thumbnails.medium.image

      return Observable.of(currentVideoItem)
    }.debug()
  }
  
  private func channelsWithThumbnailsFrom(videoItems: Observable<VideoItem>) -> Observable<ChannelItem> {
    videoItems.reduce([]) { (acc, videoItem) -> [String] in
      let channelId = videoItem.snippet.channelId
      
      if acc.contains(channelId) {
        return acc
      }
      
      return acc + [channelId]
    }
    .flatMap { (channels) -> Observable<ChannelItem> in
      guard let channelURL = Endpoints.channels(id: channels.joined(separator: ",")).url else {
        return Observable.empty()
      }
      print(Endpoints.channels(id: channels.joined(separator: ",")).stringValue)
      let channelsResponse: Observable<Channel> = Request.fetchJSON(url: channelURL)
      return channelsResponse.flatMap { (channel) -> Observable<ChannelItem> in
        Observable.from(channel.items)
      }
    }
    .flatMap { (channelItem) -> Observable<ChannelItem> in
      let channelThumbnailURLString = channelItem.snippet.thumbnails.medium.url
      guard let channelThumbnailURL = URL(string: channelThumbnailURLString) else {
        return Observable.empty()
      }
      return Request.fetch(url: channelThumbnailURL)
        .flatMap { (image) -> Observable<ChannelItem> in
          var currentChannel = channelItem
          currentChannel.snippet.thumbnails.medium.image = image
          
          return Observable.of(currentChannel)
        }
    }
  }
  
  private func videosWithThumbnailsFrom(videoItems: Observable<VideoItem>) -> Observable<VideoItem> {
    videoItems.flatMap { (videoItem) -> Observable<VideoItem> in
      let thumbnailURLString = videoItem.snippet.thumbnails.medium.url
      guard let thumbnailURL = URL(string: thumbnailURLString) else {
        throw Request.RequestError.invalidURL(string: thumbnailURLString)
      }
      let thumbnailData = Request.fetch(url: thumbnailURL)
      
      return thumbnailData
        .flatMap { (thumbnail) -> Observable<VideoItem> in
          var myVideoItem = videoItem
          myVideoItem.snippet.thumbnails.medium.image = thumbnail
          
          return Observable.of(myVideoItem)
        }
    }
  }
}
