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
    
    var url: URL? {
      return URL(string: stringValue)
    }
  }
  
  func search(q: String) -> Observable<[Item]> {
    guard let url = Endpoints.search(q: q).url else { return Observable.empty() }
    let search: Observable<Search> = Request.fetchJSON(url: url)
    
    return search
      .flatMap { (search) -> Observable<Item> in
        Observable.from(search.items)
      }
      .map { (item) -> (Item, Observable<Data>) in
        let imageMetadata = item.snippet.thumbnails.medium
        let urlString = imageMetadata.url
        guard let url = URL(string: urlString) else {
          throw RequestError.invalidURL(s: urlString)
        }
        
        return (item, Request.fetch(url: url))
      }
      .flatMap { (item, data) -> Observable<Item> in
        data.map { (data) -> Item in
          var myItem = item
          myItem.snippet.thumbnails.medium.image = data
          return myItem
        }
      }
      .reduce([]) { (acc, Item) -> [Item] in
        return acc + [Item]
      }
      .observeOn(MainScheduler.instance)
  }
}
