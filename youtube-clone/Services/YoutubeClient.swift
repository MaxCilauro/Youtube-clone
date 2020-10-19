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
    case statistics(id: String)
    case popular
    
    var stringValue: String {
      switch self {
      case .search(let q):
        return Endpoints.base + "/search" + Endpoints.apiKeyParam + "&part=snippet&q=\(q)&maxResults=10&type=channel,video"
      case .channels(let id):
        return Endpoints.base + "/channels" + Endpoints.apiKeyParam + "&part=snippet,statistics&id=\(id)"
      case .statistics(let id):
        return Endpoints.base + "/videos" + Endpoints.apiKeyParam + "&part=statistics&id=\(id)"
      case .popular:
        return Endpoints.base + "/videos" + Endpoints.apiKeyParam + "&part=statistics,snippet&chart=mostPopular"
      }
    }
    
    var url: URL? {
      return URL(string: stringValue)
    }
  }
  
  func search(query: String) -> Observable<[Video]> {
    guard let parsedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
          let url = Endpoints.search(q: parsedQuery).url else {
      return Observable.empty()
    }
    
    return getVideosFrom(url: url)
  }
  
  func getMostPopularVideos() -> Observable<[Video]> {
    guard let url = Endpoints.popular.url else { return Observable.empty() }
    
    return getVideosFrom(url: url)
  }
  
  private func getVideosFrom(url: URL) -> Observable<[Video]> {
    let sharedVideoResponse: Observable<YoutubeResponse> = Request.fetchJSON(url: url).share(replay: 1)
    
    let channels: Observable<[Channel]> = channelsWithThumbnailsFrom(videoResponse: sharedVideoResponse)
    let items: Observable<[VideoItemWithThumbnail]> = videoItemsWithThumbnailsFrom(videoResponse: sharedVideoResponse)
    
    return generateVideosFor(items: items, with: channels)
  }
  
  fileprivate func generateVideosFor(items: Observable<[VideoItemWithThumbnail]>, with channels: Observable<[Channel]>) -> Observable<[Video]> {
    return Observable
      .zip(items, channels)
      .map { (items, channels) -> [Video] in
        items.map { (item) -> Video in
          Video(
            id: item.id,
            channelId: item.channelId,
            kind:  item.kind,
            title: item.title,
            description: item.description,
            statistics: item.statistics,
            channel: channels.first(where: { $0.id == item.channelId }) ?? Channel.empty,
            thumbnail: item.thumbnail,
            publishedAt: item.publishedAt)
        }
      }
  }
  
  private func channelsWithThumbnailsFrom(videoResponse: Observable<YoutubeResponse>) -> Observable<[Channel]> {
    videoResponse.flatMap({ (response) -> Observable<YoutubeItem> in
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
        description: channelItem.snippet.description,
        videoCount: channelItem.statistics.videoCount,
        subscriberCount: channelItem.statistics.subscriberCount
      )
    }
  }
  
  private func videoItemsWithThumbnailsFrom(videoResponse: Observable<YoutubeResponse>) -> Observable<[VideoItemWithThumbnail]> {
    videoResponse.flatMap { (response) -> Observable<[VideoItemWithThumbnail]> in
      Observable.zip(response.items.map({ self.getVideo(youtubeItem: $0) }))
    }
  }
  
  private func getVideo(youtubeItem: YoutubeItem) -> Observable<VideoItemWithThumbnail> {
    let thumbnailURLString = youtubeItem.snippet.thumbnails.maxRes?.url ?? youtubeItem.snippet.thumbnails.medium.url
    guard let thumbnailURL = URL(string: thumbnailURLString) else {
      return Observable.empty()
    }
    
    let statistics = getStatistics(for: youtubeItem)
    let thumbnail = Request.fetch(url: thumbnailURL)
    return Observable.zip(statistics, thumbnail).map({ (statistics, imageData) -> VideoItemWithThumbnail in
      VideoItemWithThumbnail(
        id: youtubeItem.itemId.id ?? "",
        channelId: youtubeItem.snippet.channelId,
        kind: youtubeItem.itemId.kind ?? youtubeItem.kind,
        title: youtubeItem.snippet.title,
        description: youtubeItem.snippet.description,
        statistics: statistics,
        thumbnail: UIImage(data: imageData), publishedAt: youtubeItem.snippet.publishedAt
      )
    })
  }
  
  private func getStatistics(for youtubeItem: YoutubeItem) -> Observable<Statistics> {
    if let statistics = youtubeItem.statistics {
      return Observable.just(statistics)
    }
    
    guard let id = youtubeItem.itemId.id, let url = Endpoints.statistics(id: id).url else {
      return Observable.empty()
    }
    
    let videoListResponse: Observable<StatisticsResponse> = Request.fetchJSON(url: url)
    
    return videoListResponse.map { (response) -> Statistics in
      guard let statistics = response.items.first?.statistics else {
        return Statistics.empty
      }
      
      return statistics
    }
  }
}
