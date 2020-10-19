//
//  VideoHelpers.swift
//  youtube-clone
//
//  Created by Yaku on 16/10/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

class VideoHelpers {
  static func getMetadataFrom(video: Video) -> String {
    let views = video.statistics.viewCount
    let dateFormatter = ISO8601DateFormatter()
    let date = dateFormatter.date(from: video.publishedAt)!
    let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
    return "\(views) views・\(components.day!)/\(components.month!)/\(components.year!)"
  }
  
  static func getFormattedSubscriberCount(channel: Channel) -> String {
    guard let subscriberCount = Float(channel.subscriberCount) else { return "" }
    let formattedSubscriberCount = formatSubscriberCount(count: subscriberCount)
    
    return "\(formattedSubscriberCount) subscribers"
  }
  
  static func getFormattedVideoCount(channel: Channel) -> String {
    "\(channel.videoCount) videos"
  }

  private static func formatSubscriberCount(count: Float, steps: Int = 0) -> String {
    let rest = count / 1000
    if rest >= 1 {
      return formatSubscriberCount(count: rest, steps: steps + 1)
    }
    
    let kiloSuffix = [String](repeating: "K", count: steps).joined()
    
    return "\(Int(count))\(kiloSuffix)"
  }
}
