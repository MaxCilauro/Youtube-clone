//
//  SearchResultCell.swift
//  youtube-clone
//
//  Created by Yaku on 09/09/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
  static let identifier = "SearchResultTableViewCell"
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var channelLabel: UILabel!
  @IBOutlet weak var metadataLabel: UILabel!
  
  var video: Video? {
    didSet {
      guard let video = video else { return }
      
      thumbnailImageView.image = video.thumbnail
      titleLabel.text = video.title
      channelLabel.text = video.channel.title
      metadataLabel.text = VideoHelpers.getMetadataFrom(video: video)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
