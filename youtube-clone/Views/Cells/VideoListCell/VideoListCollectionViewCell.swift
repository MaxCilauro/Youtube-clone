//
//  VideoListCollectionViewCell.swift
//  youtube-clone
//
//  Created by Yaku on 06/10/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import UIKit

class VideoListCollectionViewCell: UICollectionViewCell {
  static let identifier = "videoCell"
  
  var video: Video? {
    didSet {
      guard let video = video else { return }
      
      thumbnailImageView.image = video.thumbnail
      channelImageView.image = video.channel.image
      
      titleLabel.text = video.title
      
      channelName.text = video.channel.title
      metadataLabel.text = VideoHelpers.getMetadataFrom(video: video)
    }
  }
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var channelImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var channelName: UILabel!
  @IBOutlet weak var metadataLabel: UILabel!
  @IBOutlet private var maxWidthConstraint: NSLayoutConstraint! {
    didSet {
      maxWidthConstraint.isActive = false
    }
  }
  
  var maxWidth: CGFloat? = nil {
    didSet {
      guard let maxWidth = maxWidth else {
        return
      }
      maxWidthConstraint.isActive = true
      maxWidthConstraint.constant = maxWidth
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.leftAnchor.constraint(equalTo: leftAnchor),
      contentView.rightAnchor.constraint(equalTo: rightAnchor),
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    channelImageView.layer.cornerRadius = channelImageView.frame.width / 2
  }
}
