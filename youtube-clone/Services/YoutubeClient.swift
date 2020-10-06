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
  static let apiKey = Secrets.youtubeApiKey.rawValue
  
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
  
  func getMostPopularVideos() -> Observable<[Video]> {
    guard let url = Endpoints.popular.url else { return Observable.empty() }
    let sharedVideoResponse: Observable<VideoResponse> = Request.fetchJSON(url: url).share(replay: 1)
    
    let channels: Observable<[Channel]> = channelsWithThumbnailsFrom(videoResponse: sharedVideoResponse)
    let items: Observable<[VideoItemWithThumbnail]> = videoItemsWithThumbnailsFrom(videoResponse: sharedVideoResponse)
    
    return Observable
      .zip(items, channels)
      .map { (items, channels) -> [Video] in
        items.map { (item) -> Video in
          Video(
            id: item.id,
            channelId: item.channelId,
            title: item.title,
            description: item.description,
            statistics: item.statistics,
            channel: channels.first(where: { $0.id == item.channelId }) ?? Channel.empty,
            thumbnail: item.thumbnail,
            publishedAt: item.publishedAt)
        }
      }
  }
  
  private func channelsWithThumbnailsFrom(videoResponse: Observable<VideoResponse>) -> Observable<[Channel]> {
    videoResponse.flatMap({ (response) -> Observable<VideoItem> in
      Observable.from(response.items)
    })
    .reduce([]) { (acc, videoItem) -> [String] in
      let channelId = videoItem.snippet.channelId
      
      if acc.contains(channelId) {
        return acc
      }
      
      return acc + [channelId]
    }
    .flatMap { (channels) -> Observable<[Channel]> in
      guard let channelURL = Endpoints.channels(id: channels.joined(separator: ",")).url else {
        return Observable.empty()
      }
      let channelsResponse: Observable<ChannelResponse> = Request.fetchJSON(url: channelURL)
      return channelsResponse.flatMap { (response) -> Observable<[Channel]> in
        Observable.zip(response.items.map({ self.getChannel(channelItem: $0) }))
      }
    }
  }
  
  private func getChannel(channelItem: ChannelItem) -> Observable<Channel> {
    guard let url = URL(string: channelItem.snippet.thumbnails.medium.url) else {
      return Observable.empty()
    }
    
    return Request.fetch(url: url).map { (imageData) -> Channel in
      Channel(
        id: channelItem.id,
        image: UIImage(data: imageData),
        title: channelItem.snippet.title,
        description: channelItem.snippet.description
      )
    }
  }
  
  private func videoItemsWithThumbnailsFrom(videoResponse: Observable<VideoResponse>) -> Observable<[VideoItemWithThumbnail]> {
    videoResponse.flatMap { (response) -> Observable<[VideoItemWithThumbnail]> in
      Observable.zip(response.items.map({ self.getVideo(videoItem: $0) }))
    }
  }
  
  private func getVideo(videoItem: VideoItem) -> Observable<VideoItemWithThumbnail> {
    let thumbnailURLString = videoItem.snippet.thumbnails.medium.url
    guard let thumbnailURL = URL(string: thumbnailURLString) else {
      return Observable.empty()
    }
    
    return Request.fetch(url: thumbnailURL)
      .map { (imageData) -> VideoItemWithThumbnail in
        VideoItemWithThumbnail(
          id: videoItem.id,
          channelId: videoItem.snippet.channelId,
          title: videoItem.snippet.title,
          description: videoItem.snippet.description,
          statistics: videoItem.statistics,
          thumbnail: UIImage(data: imageData), publishedAt: videoItem.snippet.publishedAt)
      }
  }
}
