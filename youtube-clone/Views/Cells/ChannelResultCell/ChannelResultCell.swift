//
//  ChannelResultCell.swift
//  youtube-clone
//
//  Created by Yaku on 09/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class ChannelResultCell: UITableViewCell {
  static let identifier = "ChannelResultTableViewCell"
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subscriberCountLabel: UILabel!
  @IBOutlet weak var videoCountLabel: UILabel!
  
  var video: Video? {
    didSet {
      guard let video = video else { return }
      
      thumbnailImageView.image = video.thumbnail
      titleLabel.text = video.title
      subscriberCountLabel.text = VideoHelpers.getFormattedSubscriberCount(channel: video.channel)
      videoCountLabel.text = VideoHelpers.getFormattedVideoCount(channel: video.channel)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

    thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.width / 2
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
