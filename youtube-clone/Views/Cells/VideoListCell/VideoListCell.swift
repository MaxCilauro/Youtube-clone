//
//  VideoListCell.swift
//  youtube-clone
//
//  Created by Yaku on 11/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class VideoListCell: UICollectionViewCell {
  static let identifier = "videoCell"
  
  var video: Video? {
    didSet {
      guard let video = video else { return }
      
      thumbnailImageView.image = video.thumbnail
      channelImageView.image = video.channel.image
      
      titleLabel.text = video.title
      
      channelName.text = video.channel.title
      metadataLabel.text = getMetadata()
    }
  }
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var channelImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var channelName: UILabel!
  @IBOutlet weak var metadataLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    channelImageView.layer.cornerRadius = channelImageView.frame.width / 2
  }
  
  func getMetadata() -> String {
    guard let video = video else { return "" }
    let views = video.statistics.viewCount
    let dateFormatter = ISO8601DateFormatter()
    let date = dateFormatter.date(from: video.publishedAt)!
    let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
    return "\(views) views・\(components.day!)/\(components.month!)/\(components.year!)"
  }
}
