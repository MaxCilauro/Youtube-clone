//
//  VideoItemWithThumbnail.swift
//  youtube-clone
//
//  Created by Yaku on 03/10/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation
import UIKit

struct VideoItemWithThumbnail {
  let id: String
  let channelId: String
  let kind: String
  let title: String
  let description: String
  let statistics: Statistics
  let thumbnail: UIImage?
  let publishedAt: String
}
