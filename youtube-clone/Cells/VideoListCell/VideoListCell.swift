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
    
    var videoItem: Item? {
        didSet {
            guard let videoItem = videoItem,
                let thumbnailData = videoItem.snippet.thumbnails.medium.image,
                let channelImage = videoItem.snippet.channelImage else {
                    return
            }
            
            thumbnailImageView.image = UIImage(data: thumbnailData)
            channelImageView.image = UIImage(data: channelImage)
            
            titleLabel.text = videoItem.snippet.title

            channelName.text = videoItem.snippet.channelTitle
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
        guard let item = videoItem, let stats = item.id.statistics else { return "" }
        let views = stats.viewCount
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: item.snippet.publishedAt)!
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return "\(views) views・\(components.day!)/\(components.month!)/\(components.year!)"
    }
}
